# require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require_relative "support/coverage"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
# require 'spec_helper'
require 'rails_helper'
require 'rspec/rails'
# require 'capybara/rails'

Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }
# include Warden::Test::Helpers
# Warden.test_mode!

unless Rails.env.development?
  begin
    ActiveRecord::Migration.maintain_test_schema!
  rescue ActiveRecord::PendingMigrationError => e
    abort e.to_s.strip
  end
end

RSpec.configure do |config|
  config.filter_rails_from_backtrace!
  config.fixture_paths = [File.join(::Rails.root, 'test', 'fixtures')]
  config.use_transactional_fixtures = false

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  config.include Request::JsonHelpers, type: :request
end

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

RSpec.configure do |config|
  config.before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end
end

