module Hotfolder
  module CreateFilesCommand
    extend self

    def execute(files, ingest_type)
      unless files.empty?
        upload_data = files.map { |f| f.metadata.runner_object }
        response = RunnerClient::API.create_asset_items_for_upload(upload_data, ingest_type)
        if response.success?
          Hotfolder.logger.try(:info, "Successfully created #{files.map(&:basename)}")
        else
          Hotfolder.logger.try(:error, "ERROR CREATING #{files.map(&:basename)} #{response.body}")
        end
      end
    end
  end
end
