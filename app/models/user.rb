class User < ActiveRecord::Base
  validates_presence_of :uid, :twitter_id, :twitter_handle, :twitter_token
  
  before_validation :generate_uid, :on => :create
  
  has_many :videos
  has_many :comments
  
  acts_as_authentic do |c|
    c.merge_validates_length_of_email_field_options({:unless => :has_authorizations?})
    c.merge_validates_format_of_email_field_options({:unless => :has_authorizations?})
    c.merge_validates_confirmation_of_password_field_options({:unless => :has_authorizations?})
    c.merge_validates_length_of_password_confirmation_field_options({:unless => :has_authorizations?})
    c.merge_validates_length_of_password_field_options({:unless => :has_authorizations?})
  end
  
  def tweet(message)
    
    user = Twitter::Client.new(:oauth_token => self.oauth_token, :oauth_token_secret => self.oauth_token_secret)
    user.update(message)
  end 
  
  def follow_frtr
    user = Twitter::Client.new(:oauth_token => self.oauth_token, :oauth_token_secret => self.oauth_token_secret)
    user.follow("frtr_me")
  end 
  
  def has_authorizations?
    true
  end
  
  def generate_uid
    self.uid = UUID.generate
  end
end
