require "nummer"

module Hotfolder
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def hotfolder_ingest_type(ingest_type)
      class_variable_set(:@@ingest_type, ingest_type)
    end
  end

  attr_reader :ingest_type

  def initialize
    if self.class.class_variables.include? :@@ingest_type
      @ingest_type = self.class.class_variable_get :@@ingest_type
    else
      raise "hotfolder_ingest_type is not set"
    end

    validate
  end

  def execute
    get_in_progress_asset_item_names
  end

  def validate
    validate_runner_client_ingest_type
  end

  def hotfolder_logger
    @logger
  end

  def hotfolder_logger=(logger)
    @logger = logger
  end


  private

  def validate_runner_client_ingest_type
    unless Nummer::IngestType.values.include? @ingest_type
      raise "hotfolder_ingest_type is invalid"
    end
  end

  def get_in_progress_asset_item_names
    response = RunnerClient::API.get_in_progress_ingests(@ingest_type)
    raise 'Error retrieving in progress ingests' unless response.success?

    response.in_progress_ingests.map { |ingest| ingest.file_name }
  end
end
