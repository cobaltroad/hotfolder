module Hotfolder
  module GetInProgressCommand
    extend self

    def execute(ingest_type, options={})
      response = RunnerClient::API.get_in_progress_ingests(ingest_type)
      raise 'Error retrieving in progress ingests' unless response.success?

      in_progress = response.in_progress_ingests.map { |ingest| ingest.file_name }
      Hotfolder.log "In-progress #{ingest_type} files: #{in_progress}"
      in_progress
    end
  end
end
