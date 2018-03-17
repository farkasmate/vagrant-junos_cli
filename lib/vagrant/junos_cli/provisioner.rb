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
        @machine.config.ssh.shell = 'start shell' unless @machine.config.ssh.username == 'root'

        with_script_file do |path|
          @machine.communicate.tap do |comm|
            # Reset upload path permissions for the current ssh user
            info = nil
            retryable(on: Vagrant::Errors::SSHNotReady, tries: 3, sleep: 2) do
              info = @machine.ssh_info
              raise Vagrant::Errors::SSHNotReady if info.nil?
            end

            user = info[:username]
            comm.sudo("chown -R #{user} #{config.upload_path}",
                      error_check: false)

            comm.upload(path.to_s, config.upload_path)

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
fi'"

            cli_oneliner = "/usr/sbin/cli -f #{config.upload_path}"

            clean_up = "/bin/rm #{config.upload_path}"

            [prepare, cli_oneliner, clean_up].each do |command|
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
