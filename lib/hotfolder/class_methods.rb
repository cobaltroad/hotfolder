module Hotfolder
  module ClassMethods
    def hotfolder_ingest_type(ingest_type)
      class_variable_set(:@@ingest_type, ingest_type)
    end
  end
end
