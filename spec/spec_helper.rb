require 'bundler/setup'
Bundler.setup
#require 'webmock/rspec'
require 'helpers/utility'

RSpec.configure do |config|
  config.alias_example_to :fit, focus: true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  #config.after(:suite) { WebMock.disable! }
end
