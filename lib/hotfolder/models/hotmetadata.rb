module Hotfolder
  class Hotmetadata
    attr_accessor :gpms_ids
    attr_accessor :name
    attr_accessor :folder_ids

    def initialize(file, metadata_config={})
      @name = file.basename

      if self.class.instance_methods.include? :on_initialize
        on_initialize(file, metadata_config)
      else
        @gpms_ids   = metadata_config[:gpms_ids]
        @folder_ids = metadata_config[:folder_ids]
      end
    end

    def runner_object
      obj = {
        name: @name
      }
      obj.merge!(gpms_ids: @gpms_ids) if @gpms_ids
      obj.merge!(folder_ids: @folder_ids) if @folder_ids
      obj
    end
  end
end
