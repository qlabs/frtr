# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Fritter::Application.initialize!

Framey.configure do |config|
  config.api_key = AppConfigs["framey"]["api_key"]
  config.api_secret = AppConfigs["framey"]["secret"]
  config.api_host = AppConfigs["framey"]["api_host"] if AppConfigs["framey"]["api_host"] 
  config.run_env = AppConfigs["framey"]["run_env"] if AppConfigs["framey"]["run_env"]
end

BITLY_USER = AppConfigs["bitly"]["user_name"]
BITLY_API_KEY = AppConfigs["bitly"]["api_key"]
FRTR_HOST = AppConfigs["frtr"]["frtr_host"]

WillPaginate::ViewHelpers.pagination_options[:previous_label] = "< PREV"
WillPaginate::ViewHelpers.pagination_options[:next_label] = "NEXT >"