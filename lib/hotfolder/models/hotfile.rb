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

    def ready?(delay_in_hours)
      seconds_in_an_hour = 3600
      delayed_time = Time.now - (seconds_in_an_hour * delay_in_hours)
      @mtime < delayed_time
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