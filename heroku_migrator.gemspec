# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'heroku_migrator/version'

Gem::Specification.new do |gem|
  gem.name          = 'heroku_migrator'
  gem.version       = HerokuMigrator::VERSION
  gem.authors       = ['James Conroy-Finn']
  gem.email         = ['james@logi.cl']
  gem.description   = %q{Migrate your deprecated Heroku database quickly}
  gem.summary       = %q{Migrate your deprecated Heroku database quickly}
  gem.homepage      = 'https://github.com/evently/heroku_migrator'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'heroku', '~> 2.30'
  gem.add_dependency 'thor', '~> 0.15'

  gem.required_ruby_version = Gem::Requirement.new('~> 1.9')
  gem.post_install_message = <<EOS
This gem is provided AS-IS with no warranty or guarantees!

If you run this gem you will be moving data in your Heroku database. There's a
chance you will lose data. Back everything up before you even think about
running heroku_migrator!
EOS
end
