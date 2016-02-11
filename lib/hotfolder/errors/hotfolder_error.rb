module Hotfolder
  class HotfolderError < StandardError
    def initialize(message=nil)
      super(message)
    end
  end
end
