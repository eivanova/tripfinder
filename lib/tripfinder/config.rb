require 'yaml'

module Tripfinder

  @version = 0.1

  @config = {
    :points => "../../datasets/points.txt",
    :routes => "../../datasets/routes.txt"
  }	

  @valid_config_keys = @config.keys

  # Configure through hash
  def self.configure(opts = {})
    opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
  end

  def self.configure_with(path_to_yaml_file)
    begin
      config = YAML::load(IO.read(path_to_yaml_file))
    rescue Errno::ENOENT
      log(:warning, "YAML configuration file couldn't be found. Using defaults."); return
    rescue Psych::SyntaxError
      log(:warning, "YAML configuration file contains invalid syntax. Using defaults."); return
   end

   configure(config)
  end

  def self.config
    @config
  end

  def self.VERSION
    @version	  
  end

end
