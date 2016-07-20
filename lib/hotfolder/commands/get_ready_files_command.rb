module Hotfolder
  module GetReadyFilesCommand
    extend self

    def execute(new_hotfiles, delay_in_seconds)
      ready = new_hotfiles.select do |hotfile|
        hotfile.ready? delay_in_seconds
      end
      Hotfolder.logger.try(:info, "Ready files: #{ready.map(&:basename)}")
      ready
    end
  end
end
