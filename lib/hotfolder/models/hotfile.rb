module Hotfolder
  class Hotfile
    attr_accessor :path
    attr_accessor :basename
    attr_accessor :size
    attr_accessor :mtime
    attr_accessor :metadata

    def initialize(hash)
      @path     = hash['path']
      @basename = hash['basename']
      @size     = hash['size']
      @mtime    = Time.parse(hash['mtime'])
      @metadata = nil
    end

    def inspect
      [
        "<#{self.class.name} basename: \"#{@basename}\"",
        "path: \"#{@path}\"",
        "mtime: \"#{@mtime}\"",
        "size: #{@size}",
        "metadata: #{metadata_string}>"
      ].join(', ')
    end

    def metadata_string
      @metadata.nil? ? 'nil' : @metadata
    end

    def now
      Time.now.to_i
    end

    def ready?(delay_in_seconds)
      delayed_time = now - delay_in_seconds
      @mtime.to_i < delayed_time
    end

    def build_metadata_using(metadata_config)
      metadata_dup = metadata_config.dup
      begin
        if metadata_dup[:class_name]
          klass = metadata_dup.delete(:class_name).constantize
        else
          klass = Hotfolder::Hotmetadata
        end
        @metadata = klass.new(self, metadata_dup)
      rescue ArgumentError
        msg = "#{klass.name}.initialize should accept an instance of Hotfile"
        raise HotfolderError, msg
      end
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
