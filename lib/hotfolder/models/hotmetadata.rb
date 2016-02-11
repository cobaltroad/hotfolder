module Hotfolder
  class Hotmetadata
    attr_accessor :gpms_ids
    attr_accessor :name
    attr_accessor :folder_ids

    def initialize(file)
      @name = file.basename
      if self.class.instance_methods.include? :on_initialize
        on_initialize(file)
      end
    end

    def runner_object
      {
        gpms_ids: @gpms_ids,
        name: @name,
        folder_ids: @folder_ids
      }
    end
  end
end
