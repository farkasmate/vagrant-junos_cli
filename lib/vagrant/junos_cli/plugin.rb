require 'vagrant'

module Vagrant
  module JunosCli
    class Plugin < VagrantPlugins::Shell::Plugin
      name 'junos_cli'
      description <<-DESC
      Junos CLI provisioner.
      DESC

      config(:junos_cli, :provisioner) do
        require File.expand_path('../config', __FILE__)
        Config
      end

      provisioner(:junos_cli) do
        require File.expand_path('../provisioner', __FILE__)
        Provisioner
      end
    end
  end
end
