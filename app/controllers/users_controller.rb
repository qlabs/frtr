class UsersController < ApplicationController
  before_filter :fetch_user, :except => [:index, :new_video]
  before_filter :require_user, :except => [:index, :new_video]
  before_filter :require_same_user, :only => [:show]
  
  # GET /
  def index
    
  
  end

  # GET /users/ssalzberg
  def show
    @videos = current_user.videos.paginate :page => (params[:page] || 1) , :order => 'created_at DESC', :per_page => 4
    @user = current_user
    @video_uid = UUID.generate    

    respond_to do |format|
      format.html
      format.js
    end    
  end

  def new_video
    render :nothing => true, :json => {:video_uid => UUID.generate}.to_json 

  end
end
