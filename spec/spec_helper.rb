require 'dummy/application'
require 'rspec/rails'
require 'rails-controller-testing'
require 'capybara/rspec'
require 'database_cleaner'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include ParamsWrapper
  config.include Rails::Controller::Testing::TestProcess, type: :controller

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
