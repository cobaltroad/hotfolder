require 'hotfolder'

class Example
  include Hotfolder

  hotfolder_ingest_type Nummer::IngestType::RUNNER
end
