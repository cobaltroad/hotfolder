module Hotfolder
  module InstanceMethods
    attr_reader :ingest_type

    def initialize
      if self.class.class_variables.include? :@@ingest_type
        @ingest_type = self.class.class_variable_get :@@ingest_type
      else
        raise "hotfolder_ingest_type is not set"
      end

      validate
    end

    def in_progress
      GetInProgressCommand.execute(@ingest_type)
    end

    def hotfolder_logger
      @logger
    end

    def hotfolder_logger=(logger)
      @logger = logger
    end

    private

    def validate
      validate_runner_client_ingest_type
    end

    def validate_runner_client_ingest_type
      unless Nummer::IngestType.values.include? @ingest_type
        raise "hotfolder_ingest_type is invalid"
      end
    end
  end
end
