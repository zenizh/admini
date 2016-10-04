$:.push File.expand_path('../lib', __FILE__)

require 'admini/version'

Gem::Specification.new do |s|
  s.name        = 'admini'
  s.version     = Admini::VERSION
  s.authors     = 'kami'
  s.email       = 'hiroki.zenigami@gmail.com'
  s.homepage    = 'https://github.com/kami-zh/admini'
  s.summary     = 'A minimal administration framework for Ruby on Rails application.'
  s.description = 'A minimal administration framework for Ruby on Rails application.'
  s.license     = 'MIT'

  s.files = `git ls-files -z`.split("\x0")

  s.add_dependency 'actionview'
  s.add_dependency 'activesupport'
  s.add_dependency 'simple_form'
  s.add_dependency 'kaminari'
  s.add_dependency 'jquery-rails'

  s.add_development_dependency 'actionpack'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'database_cleaner'
end
