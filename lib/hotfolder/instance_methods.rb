module Hotfolder
  module InstanceMethods
    include InstanceHelpers
    attr_reader :name

    attr_reader :aspera_username
    attr_reader :aspera_password
    attr_reader :aspera_endpoint
    attr_reader :source_file_path

    attr_reader :file_pickup_delay_hours
    attr_reader :ingest_type
    attr_reader :runner_path_id
    attr_reader :upload_batch_size_mb

    def initialize
      load_config_hash
      load_ingest_type

      validate
    end

    def in_progress
      GetInProgressCommand.execute(@ingest_type)
    end

    def files
      GetFilesCommand.execute(
        @aspera_endpoint,
        @aspera_path,
        @aspera_username,
        @aspera_password
      )
    end

    private

    def load_config_hash
      config = class_var(:@@config)
      if config && config.is_a?(Hash)
        hash = config.with_indifferent_access
        @name                    = hash[:name]

        @aspera_username         = hash[:aspera_username]
        @aspera_password         = hash[:aspera_password]
        @aspera_endpoint         = hash[:aspera_endpoint]
        @source_file_path        = hash[:source_file_path]

        @file_pickup_delay_hours = hash[:file_pickup_delay_hours]
        @runner_path_id          = hash[:runner_path_id]
        @upload_batch_size_mb    = hash[:upload_batch_size_mb]
      end
    end

    def load_ingest_type
      @ingest_type = class_var(:@@ingest_type) do
        raise "hotfolder_ingest_type is not set"
      end
    end

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
