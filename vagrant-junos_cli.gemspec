lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant/junos_cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-junos_cli'
  spec.version       = Vagrant::JunosCli::VERSION
  spec.authors       = ['Mate Farkas']
  spec.email         = ['mate.farkas@sch.hu']

  spec.summary       = 'Provision Junos OS boxes using CLI commands.'
  spec.homepage      = 'https://github.com/farkasmate/vagrant-junos_cli'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16.a'
  spec.add_development_dependency 'rake', '~> 13.0'
end
