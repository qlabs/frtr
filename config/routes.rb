Fritter::Application.routes.draw do
  
  # resources :videos, :only => [:index,:create,:show] do
  #   member do
  #     match "callback"
  #   end
  # end

  resource :user_session do
    member { get :auth_and_return_to }
  end
  
  get "/users/new_video" => "users#new_video", :as => "new_video"
  match "/users/:twitter_handle" => "users#show", :as => "record"
  match "/auth/twitter/callback" => "user_sessions#create"
  match "/logout" => "user_sessions#destroy", :as => "logout"
  match '/auth/failure' => 'user_sessions#authfail'
  match "/videos/callback" => "videos#callback"
  post "/videos/tweet" => "videos#tweet"
  post "/videos" => "videos#create"
  get "/videos" => "videos#index"
  delete "/videos/:uid" => "videos#delete"
  get "/videos/:uid" => "videos#show", :as => "video"
  match "/videos/:uid/source.flv" => "videos#source", :as => "video_source"
  match "/videos/:uid/thumbnail.jpg" => "videos#thumbnail", :as => "video_thumbnail"
  match "/videos/:uid/like" => "videos#like", :as => "like_video"
  match "/videos/:uid/comment" => "videos#comment", :as => "comment_on_video"
  match "/" => "users#index", :as => "home"
end
