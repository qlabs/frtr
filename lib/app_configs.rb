require 'yaml'
require 'fileutils'

module AppConfigs    
  @@configs = Hash.new
  
  # Return hash of settings for current environment from named config (YAML) file.
  def self.[](config_file)
    whole_config = config(config_file)

    yaml = whole_config[Rails.env] || whole_config

    yaml
  end
  
  # Return hash from reading named YAML file and substituting values from hostname.yml.
  def self.config(config_file)
    # this will load and return from the cache before going to disk
    return @@configs[config_file] if @@configs[config_file]
    
    path_to_file = File.join(Rails.root, 'config', "app_configs", "#{config_file.to_s}.yml")

    if File.exists?(path_to_file)
      config_string = File.read(path_to_file)
    else
      raise NotImplementedError
    end
    
    @@configs[config_file] = YAML.load(config_string)
  end

end
