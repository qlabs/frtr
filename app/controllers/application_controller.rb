class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user_session, :current_user, :is_current_user?
  
  private 
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  def is_current_user?(user)
    current_user && (current_user ==  user)
  end
  
  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to home_url and return
      return false
    end
  end
  
  def require_same_user
    unless current_user && @user && current_user == @user
      store_location
      flash[:notice] = "You must be logged in as that user to access this page"
      redirect_to home_url and return
      return false
    end
  end
  
  def fetch_user
    if params[:twitter_handle].to_s.downcase == "me"
      @user = current_user
    else
      @user = User.find_by_twitter_handle(params[:twitter_handle]) rescue nil
    end

    four_oh_four and return unless @user
  end
  
  def four_oh_four
    render :file => File.join(Rails.root,"public","404.html"), :status => 404 and return
  end
  
  def store_location
    session[:return_to] = request.fullpath
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
end
