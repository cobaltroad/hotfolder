module Hotfolder
  module GetReadyFilesCommand
    extend self

    def execute(new_hotfiles, delay_in_seconds)
      new_hotfiles.select do |hotfile|
        hotfile.ready? delay_in_seconds
      end
    end
  end
end
