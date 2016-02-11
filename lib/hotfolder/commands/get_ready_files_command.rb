module Hotfolder
  module GetReadyFilesCommand
    extend self

    def execute(new_hotfiles, delay_in_hours, limit)
      ready = new_hotfiles.select do |hotfile|
        hotfile.ready? delay_in_hours
      end
      Hotfolder.log "Ready files: #{ready.map(&:basename)}"
      ready.first(limit)
    end
  end
end
