module Hotfolder
  module UploadFilesCommand
    extend self

    def execute(files, ingest_type)
      files.each do |file|
        upload_data = [file.metadata.runner_object]
        response = RunnerClient::API.create_asset_items_for_upload(upload_data, @ingest_type)
        if response.success?
          Hotfolder.log "Successfully uploaded \"#{file.basename}\""
        else
          Hotfolder.log "Error uploading \"#{file.basename}\""
        end
      end
    end
  end
end
