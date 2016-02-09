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
        "slug: \"#{slug}\"",
        "revision: #{revision}",
        "gpms_ids: #{gpms_ids || 'nil'}",
        "folder_ids: #{folder_ids || 'nil'}>"
      ].join(', ')
    end

    def slug
      @metadata.try(:slug)
    end

    def revision
      @metadata.try(:revision)
    end

    def gpms_ids
      @metadata.try(:gpms_ids)
    end

    def folder_ids
      @metadata.try(:folder_ids)
    end

    def now
      Time.now.to_i
    end

    def ready?(delay_in_hours)
      seconds_in_an_hour = 3600
      delayed_time = now - (seconds_in_an_hour * delay_in_hours)
      @mtime.to_i < delayed_time
    end

    def upload!
      @metadata = Hotmetadata.new(@basename)
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
