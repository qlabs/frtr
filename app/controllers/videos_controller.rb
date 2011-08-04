class VideosController < ApplicationController
  before_filter :fetch_video, :except => [:callback,:index,:create, :like, :tweet]
  
  
  def index    
    @videos = current_user.videos.paginate :page => (params[:page] || 1) , :order => 'created_at DESC', :per_page => 10
    @user = current_user
    @likes = current_user.videos.sum("likes")
  end
  
  def delete
    logger.info("delete #{@video.framey_name}")

    success = true
    begin
      time_stamp = (DateTime.now + 1.day).to_i
      api_key = Framey.api_key
      signature = Digest::MD5.hexdigest("#{Framey.api_secret}&#{time_stamp}")      
      
      
      url = "#{Framey.api_host}/api/videos/#{@video.framey_name}?api_key=#{api_key}&time_stamp=#{time_stamp}&signature=#{signature}"
      
      logger.info(url)
      # logger.info(options.inspect)
      logger.info(HTTParty.delete("#{url}").inspect)
      
      @video.destroy
      
    rescue Exception => e
      logger.warn(e.message)
      success = false
    end

    render :nothing => true, :json => {:success => success}.to_json and return
  end
  
  # Create a video object after a user finishes recording and clicks "Publish"
  # The publish hook in the Framey recorder calls a JS function that posts 
  # the UUID of a video.  When the callback is made, the video uid is in the Framey
  # session data so that this object can be looked up and 
  def create
    u = User.find_by_uid(params[:user_uid])
    if video = Video.create(:uid => params[:video_uid], :user_id => u.id)
      @success = true
      
      # create the URL of the video
      video_url = "#{FRTR_HOST}/videos/#{params[:video_uid]}"  
      begin 
        bitly = Bitly.new(BITLY_USER, BITLY_API_KEY)
        logger.info("url: #{video_url}")
        puts "url: #{video_url}"
        url = bitly.shorten(video_url)
        @short_url = url.short_url
      rescue 
        @short_url = ""
      end
      
      video.short_link = @short_url
      video.save
      
    else
      @success = false      
    end
    
    logger.info("success == #{@success}")
    # respond_to do |format|
    #   format.html
    #   format.js {render :json => {:success => @success, :short_url => @short_url}.to_json }
    # end
    
    render :nothing => true, :json => {:success => @success, :short_url => @short_url}.to_json and return
    
  end
  
  # framey callback
  def callback
    render :text => "" and return unless request.post? && params[:video]

    video_uid = params[:video][:data][:video_uid]    
    uid = params[:video][:data][:user_uid]
    name = params[:video][:name]
    video_url = params[:video][:flv_url]
    thumbnail_url = params[:video][:medium_thumbnail_url]
    
    
    @user = User.find_by_uid(uid)
    
    render :text => "" and return unless @user
    
    video = Video.find_by_uid(video_uid)
    
    if !video
      video = Video.create!({
        :uid => video_uid,
        :framey_name => name,
        :framey_video_url => video_url,
        :framey_thumbnail_url => thumbnail_url
      })
      
      @user.videos << video
      @user.save
    else
      
      video.framey_name = name
      video.framey_video_url = video_url
      video.framey_thumbnail_url = thumbnail_url
      video.save
      
    end
    
    render :text => "" and return
  end
  
  def tweet
    success = true
    begin
      user_uid = params[:user_uid]
      video_uid = params[:video_uid]
      follow_frttr = params[:follow_frttr]
    
      twitter_text = params[:text]
    
      user = User.find_by_uid(user_uid)    
      user.tweet(twitter_text)
    
      if follow_frttr == "true"
        user.follow_frtr
      end
    
    
      #update the video with the tweet text
      video = Video.find_by_uid(video_uid)
      video.twitter_text = twitter_text
      video.save
    rescue Exception => e
      logger.info(e.message)
      puts e.message
      success = false
    end
    render :nothing => true, :json => {:success => success}.to_json and return
    
  end
  
  def show
    @comments = @video.comments.paginate(:order => "created_at DESC", :page => params[:page]||1, :per_page => 10)
  end
  
  def comment
    @video.comments.create!({
      :title => params[:title],
      :comment => params[:comment],
      :user_id => current_user ? current_user.id : nil
    })
    redirect_to video_url(@video.uid) and return
  end
  
  def source
    @video.viewed!
    redirect_to @video.framey_video_url and return
  end
  
  def thumbnail
    if @video.framey_thumbnail_url 
      redirect_to @video.framey_thumbnail_url and return
    else
      redirect_to "/images/default_thumbnail.png" and return
    end
  end
  
  def like
    video = Video.find_by_uid(params[:uid])
    if video
      video.liked!
      render :json => {:like_count => video.likes}.to_json 
    else
      render :json => {:like_count => 0}.to_json 
    end
    
  end
  
  private
  
  def fetch_video
    @video = Video.find_by_uid(params[:uid])
    four_oh_four and return unless @video
  end
end