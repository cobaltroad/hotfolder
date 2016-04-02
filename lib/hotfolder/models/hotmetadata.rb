module Hotfolder
  class Hotmetadata
    attr_accessor :gpms_ids
    attr_accessor :name
    attr_accessor :folder_ids

    def initialize(file, metadata_config={})
      @name     = file.basename
      @path     = file.path
      @username = file.username

      if self.class.instance_methods.include? :on_initialize
        on_initialize(file, metadata_config)
      else
        @gpms_ids   = metadata_config[:gpms_ids]
        @folder_ids = metadata_config[:folder_ids]
      end
    end

    def runner_object
      create_source_path_custom_metadata if @path
      create_account_key_custom_metadata if @username

      obj = {
        name: @name
      }

      obj.merge!(gpms_ids: @gpms_ids) if @gpms_ids
      obj.merge!(folder_ids: @folder_ids) if @folder_ids
      obj.merge!({ custom_metadata_fields: custom_metadata_fields}) if custom_metadata_fields.size > 0
      obj
    end

    def custom_metadata_fields
      @custom_metadata_fields ||= []
    end

    def create_account_key_custom_metadata
      custom_metadata_fields << {
        category: 'migration_info',
        label: 'account_key',
        value: @username
      }
    end

    def create_source_path_custom_metadata
      custom_metadata_fields << {
        category: 'migration_info',
        label: 'file_path',
        value: @path
      }
    end
  end
end
