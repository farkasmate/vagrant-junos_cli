module Vagrant
  module JunosCli
    class Provisioner < VagrantPlugins::Shell::Plugin.provisioner[:shell]
      include Vagrant::Util::Retryable

      def provision
        raise Vagrant::Errors::ConfigInvalid, errors: "'args' attribute is not supported by junos_cli provisioner" unless config.args.nil?
        raise Vagrant::Errors::ConfigInvalid, errors: "'env' attribute is not supported by junos_cli provisioner" unless config.env.empty?

        provision_junos_cli
      end

      protected

      def provision_junos_cli
        @machine.config.ssh.shell = 'start shell'

        with_script_file do |path|
          @machine.communicate.tap do |comm|
            # Reset upload path permissions for the current ssh user
            info = nil
            retryable(on: Vagrant::Errors::SSHNotReady, tries: 3, sleep: 2) do
              info = @machine.ssh_info
              raise Vagrant::Errors::SSHNotReady if info.nil?
            end

            if config.name
              @machine.ui.detail(I18n.t('vagrant.provisioners.shell.running',
                                        script: "script: #{config.name}"))
            elsif config.path
              @machine.ui.detail(I18n.t('vagrant.provisioners.shell.running',
                                        script: path.to_s))
            else
              @machine.ui.detail(I18n.t('vagrant.provisioners.shell.running',
                                        script: 'inline script'))
            end

            prepare = "/sbin/sh -c '\
if [ ! -d ~/.vagrant-junos_cli/bin ]; then\
  /bin/mkdir -p ~/.vagrant-junos_cli/bin;\
  /bin/ln -s /bin/echo ~/.vagrant-junos_cli/bin/printf;\
  /bin/ln -s /bin/echo ~/.vagrant-junos_cli/bin/export;\
  /bin/echo setenv PATH \\~/.vagrant-junos_cli/bin:\\$PATH >> ~/.cshrc;\
  source ~/.cshrc;\
fi'"

            cli_oneliner = format('/usr/sbin/cli -c "%s"', File.read(path).tr("\n", ';').gsub(/;+/, ';'))

            [prepare, cli_oneliner].each do |command|
              comm.execute(
                command,
                sudo: false,
                error_key: :ssh_bad_exit_status_muted
              ) do |type, data|
                handle_comm(type, data)
              end
            end
          end
        end
      end
    end
  end
end
