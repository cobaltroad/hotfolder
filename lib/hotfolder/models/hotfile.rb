module Hotfolder
  class Hotfile
    attr_accessor :path
    attr_accessor :basename
    attr_accessor :size
    attr_accessor :mtime

    def initialize(hash)
      @path     = hash['path']
      @basename = hash['basename']
      @size     = hash['size']
      @mtime    = Time.parse(hash['mtime'])
    end

    def inspect
      [
        "<#{self.class.name} ",
        "basename: \"#{@basename}\", ",
        "path: \"#{@path}\", ",
        "mtime: \"#{@mtime}\", ",
        "size: #{@size}>"
      ].join
    end

    class << self
      def build_from_response(response)
        items = JSON.parse(response.body)['items']
        if items
          items.map do |hash|
            Hotfolder::Hotfile.new(hash)
          end
        end
      end
    end
  end
end
