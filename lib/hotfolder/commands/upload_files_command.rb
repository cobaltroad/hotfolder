module Hotfolder
  module UploadFilesCommand
    extend self

    def execute(files, ingest_type)
      upload_data = files.map { |f| f.metadata.runner_object }
      response = RunnerClient::API.create_asset_items_for_upload(upload_data, @ingest_type)
      if response.success?
        Hotfolder.log "Successfully uploaded #{files.map(&:basename)}"
      else
        Hotfolder.log "Error uploading #{files.map(&:basename)}"
      end
    end
  end
end
