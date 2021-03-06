require 'dotenv'
file = File.join('config','dotenv','.env.test')
Dotenv.load(file)

require 'nummer'
require 'runner_client'
require 'httparty'
require 'aspera_client'
require 'granite_logger'

require_relative 'hotfolder/class_methods'
require_relative 'hotfolder/instance_helpers'
require_relative 'hotfolder/instance_methods'

base_folder = File.dirname(__FILE__)

[
  'commands',
  'errors',
  'models',
].each do |subfolder|
  path = File.join(base_folder, 'hotfolder', subfolder, '**', '*.rb')
  Dir[path].each { |f| require f }
end

module Hotfolder
  def self.included(klass)
    klass.extend ClassMethods
  end

  include InstanceMethods
end
