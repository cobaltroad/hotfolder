module Hotfolder
  module GetInProgressCommand
    extend self

    def execute(ingest_type)
      response = RunnerClient::API.get_in_progress_ingests(ingest_type)
      raise 'Error retrieving in progress ingests' unless response.success?

      response.in_progress_ingests.map { |ingest| ingest.file_name }
    end
  end
end
