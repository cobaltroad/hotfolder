module Hotfolder
  module ClassMethods
    def hotfolder_ingest_type(ingest_type)
      class_variable_set(:@@ingest_type, ingest_type)
    end

    def hotfolder_logger(logger, logger_method)
      @@logger = logger
      @@logger_method = logger_method
    end

    def config(config)
      class_variable_set(:@@config, config)
      self
    end
  end

  class << self
    def log(message)
      if Hotfolder::ClassMethods.class_variables.include? :@@logger
        logger = Hotfolder::ClassMethods.class_variable_get :@@logger
        logger_method = Hotfolder::ClassMethods.class_variable_get :@@logger_method
      end

      if logger && logger_method
        logger.send(logger_method, message)
      end
    end
  end
end
