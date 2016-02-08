module Hotfolder
  module InstanceHelpers

    def inspect
      [
        "<#{self.class.name} ",
        "ingest_type:\"#{@ingest_type}\", ",
        "source_file_path:\"#{@source_file_path}\">"
      ].join
    end

    private

    def class_var(symbol, &block)
      if self.class.class_variables.include? symbol
        self.class.class_variable_get symbol
      elsif block_given?
        yield block
      end
    end
  end
end
