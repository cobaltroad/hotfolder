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
    attr_reader :files_per_batch

    attr_reader :metadata_class
    attr_reader :ready_class

    def initialize
      load_config_hash
      load_ingest_type

      validate
    end

    def consume!
      in_progress_files = GetInProgressCommand.execute(@ingest_type)
      all_files         = GetFilesCommand.execute(@aspera_endpoint,
                                                  @source_file_path,
                                                  @aspera_username,
                                                  @aspera_password)

      new_files   = get_new_files(in_progress_files, all_files)
      ready_files = get_ready_files(new_files)

      files_with_metadata = gather_metadata!(ready_files)
      UploadFilesCommand.execute(files_with_metadata, @ingest_type)
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
        @files_per_batch         = hash[:files_per_batch]
        @metadata_class          = hash[:metadata_class_name].constantize
        @ready_class             = hash[:ready_class_name].try(:constantize)
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

    def get_new_files(in_progress_files, folder_files)
      folder_files.select do |file|
        !in_progress_files.include? file.basename
      end
    end

    def gather_metadata!(ready_files)
      ready_files.map do |file|
        file.build_metadata_using(@metadata_class)
        file
      end
    end

    def get_ready_files(new_files)
      klass = @ready_class || GetReadyFilesCommand
      klass.execute(new_files, @file_pickup_delay_hours, @files_per_batch)
    end
  end
end
