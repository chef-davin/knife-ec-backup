$:.unshift(File.dirname(__FILE__) + '/lib')
require 'knife_ec_backup/version'

Gem::Specification.new do |s|
  s.name = "knife-ec-backup"
  s.version = KnifeECBackup::VERSION
  s.license = 'Apache-2.0'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.summary = "Backup and Restore of Enterprise Chef"
  s.description = s.summary
  s.author = "John Keiser"
  s.email = "jkeiser@chef.io"
  s.homepage = "https://www.chef.io"

  s.required_ruby_version = ">= 2.6"

  # We need a more recent version of mixlib-cli in order to support --no- options.
  # ... but, we can live with those options not working, if it means the plugin
  # can be included with apps that have restrictive Gemfile.locks.
  # s.add_dependency "mixlib-cli", ">= 1.2.2"
  s.add_dependency "sequel", "~> 5.9"
  s.add_dependency "pg"
  s.add_dependency "chef", ">= 11.8"
  s.add_dependency "veil"
  s.add_dependency "knife-tidy"

  s.require_path = 'lib'
  s.files = %w(LICENSE README.md Rakefile) + Dir.glob("{lib,spec}/**/*")
end
