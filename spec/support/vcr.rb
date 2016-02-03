require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  [
    'RUNNER_USERNAME',
    'RUNNER_PASSWORD',
  ].each do |variable_name|
    config.filter_sensitive_data "<#{variable_name}>" do
      CGI::escape ENV[variable_name]
    end
  end
end
