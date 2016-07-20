module Hotfolder
  module InstanceMethods
    include InstanceHelpers
    attr_reader :name

    attr_reader :aspera_username
    attr_reader :aspera_password
    attr_reader :aspera_endpoint
    attr_reader :source_file_path

    attr_reader :file_pickup_delay
    attr_reader :ingest_type
    attr_reader :runner_path_id
    attr_reader :files_per_batch

    attr_reader :metadata_config
    attr_reader :ready_class

    attr_reader :files_with_metadata

    def initialize
      load_config_hash
      load_ingest_type

      validate
    end

    def consume!
      Hotfolder.logger.try(:info, "#{@name}: #{@source_file_path}")

      all_files         = get_all_files
      in_progress_files = get_in_progress_files
      new_files         = get_new_files(in_progress_files, all_files)
      ready_files       = get_ready_files(new_files)
      @files_with_metadata = gather_metadata!(ready_files)

      create_files
    end

    def create_files
      files_per_batch = @files_per_batch || 1
      num_batches = @files_with_metadata.size / files_per_batch

      if ((@files_with_metadata.size % files_per_batch) != 0)
        num_batches += 1
      end

      num_batches.times do
        batch = @files_with_metadata.slice!(0,files_per_batch)
        CreateFilesCommand.execute(batch, @ingest_type)
      end
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

        @file_pickup_delay       = maximum_delay_time(hash)
        @runner_path_id          = hash[:runner_path_id]
        @files_per_batch         = hash[:files_per_batch]

        @metadata_config         = hash[:metadata_config]
        @ready_class             = hash[:ready_class_name].try(:constantize)
      end
    end

    def load_ingest_type
      @ingest_type = class_var(:@@ingest_type) do
        raise "hotfolder_ingest_type is not set"
      end
    end

    def maximum_delay_time(hash)
      [
        hash[:file_pickup_delay_seconds].to_i,
        hash[:file_pickup_delay_minutes].to_i * 60,
        hash[:file_pickup_delay_hours].to_i * 3600
      ].max
    end

    def validate
      validate_runner_client_ingest_type
    end

    def validate_runner_client_ingest_type
      unless Nummer::IngestType.values.include? @ingest_type
        raise "hotfolder_ingest_type is invalid"
      end
    end

    def get_all_files
      files = GetFilesFromAsperaCommand.execute(
        @aspera_endpoint,
        @source_file_path,
        @aspera_username,
        @aspera_password)
      files_with_mtime = files.map { |obj| "#{obj.basename} (#{obj.mtime})" }
      Hotfolder.logger.try(:info, "#{@name}: #{files_with_mtime}")
      files
    end

    def get_in_progress_files
      in_progress = GetInProgressCommand.execute(@ingest_type)
      Hotfolder.logger.try(:info, "#{@name}: #{in_progress}")
      in_progress
    end

    def get_ready_files(new_files)
      klass = @ready_class || GetReadyFilesCommand
      files = klass.execute(new_files, @file_pickup_delay)
      Hotfolder.logger.try(:info, "#{@name}: #{files.map(&:basename)}")
      files
    end

    def get_new_files(in_progress_files, folder_files)
      folder_files.select do |file|
        !in_progress_files.include? file.basename
      end
    end

    def gather_metadata!(ready_files)
      mapped = ready_files.map do |file|
        begin
          file.build_metadata_using(@metadata_config)
          file
        rescue Exception => e
          Hotfolder.logger.try(:error, "ERROR BUILDING METADATA #{e}")
          nil
        end
      end
      mapped.compact
    end
  end
end
