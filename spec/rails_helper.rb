RSpec.configure do |config|

  # Factory Bot configuration
  config.include FactoryBot::Syntax::Methods
end

# VCR configuration
VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
end
