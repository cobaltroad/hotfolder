require_relative '../lib/hotfolder'

RSpec.configure do |config|
  config.tty = true
  config.order = :random
  config.before(:each) do
    VCR.turn_on!
  end
end

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |file| require file }
