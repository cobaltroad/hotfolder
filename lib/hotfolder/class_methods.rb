module Hotfolder
  module ClassMethods
    def hotfolder_ingest_type(ingest_type)
      class_variable_set(:@@ingest_type, ingest_type)
    end

    def hotfolder_logger(logger)
      @@logger = logger
    end

    def config(config)
      class_variable_set(:@@config, config)
      self
    end
  end

  class << self
    def logger
      if Hotfolder::ClassMethods.class_variables.include? :@@logger
        Hotfolder::ClassMethods.class_variable_get :@@logger
      end
    end
  end
end
