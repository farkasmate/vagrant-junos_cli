require 'uri'
require File.expand_path('../config.rb', VagrantPlugins::Shell::Plugin.provisioner.__internal_state[:items][:shell].source_location[0])

module Vagrant
  module JunosCli
    class Config < VagrantPlugins::Shell::Config
      attr_accessor :skip_cleanup
      attr_accessor :skip_prepare
    end
  end
end
