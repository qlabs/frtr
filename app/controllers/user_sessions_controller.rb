class UserSessionsController < ApplicationController
  
  def new
    @user_session = UserSession.new
    redirect_to home_url and return
  end  
  
  def create
    if params[:user_session]
       @user_session = UserSession.new(params[:user_session])
       if @user_session.save
         flash[:notice] = "Login successful!"
         redirect_back_or_default record_url(:twitter_handle => @user_session.user.twitter_handle)
       else
         redirect_to home_url and return
       end
     else
       auth_hash = request.env['omniauth.auth']
       
       Rails.logger.info auth_hash.inspect
       
       oauth_token = auth_hash['credentials']['token'] rescue ""
       oauth_token_secret = auth_hash['credentials']['secret'] rescue ""
       first_name = auth_hash['user_info']['first_name'] rescue ""
       last_name = auth_hash['user_info']['last_name'] rescue ""
       twitter_url = auth_hash["user_info"]["urls"]["Twitter"] rescue ""
       twitter_handle = auth_hash["extra"]["user_hash"]["screen_name"] rescue ""
       twitter_id = auth_hash["uid"]
       
       twitter_profile_image_url = auth_hash["extra"]["user_hash"]["profile_image_url"] rescue ""

       @user = User.find_by_twitter_id(twitter_id)
       
       @user ? Rails.logger.info("FOUND USER") : Rails.logger.info("CREATING USER")
       
       @user = User.new(:twitter_id => twitter_id) if !@user
       
       @user.twitter_token = oauth_token
       @user.first_name = first_name
       @user.last_name = last_name
       @user.twitter_url = twitter_url
       @user.twitter_handle = twitter_handle
       @user.twitter_profile_image_url = twitter_profile_image_url
       @user.oauth_token = oauth_token
       @user.oauth_token_secret = oauth_token_secret
       
       
       Rails.logger.info @user.inspect
       
       if !@user.save
         Rails.logger.info "COULD NOT SAVE USER: #{@user.errors.full_messages.join("\n")}"
         flash[:notice] = "User could not be created."
         redirect_back_or_default '/'
       else
         UserSession.create(@user, true)   
         Rails.logger.info "LOGGED IN!!!!"   
         flash[:notice] = "Login successful!"
         redirect_back_or_default record_url(:twitter_handle => @user.twitter_handle)
        end
     end
  end
  
  def authfail
    current_user_session.destroy if current_user_session
    flash[:notice] = "Authorization Failure!"
    redirect_back_or_default home_url
  end

  def destroy
    current_user_session.destroy
    redirect_to new_user_session_url
  end
end