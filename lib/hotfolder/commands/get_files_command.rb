module Hotfolder
  module GetFilesCommand
    extend self

    def execute(endpoint, path, username, password)
      response = HTTParty.post(browse_endpoint(endpoint),
                headers: headers,
                body: browse_body(path),
                basic_auth: basic_auth(username, password),
                verify: false)
      raise 'Error retrieving hotfolder files' unless response.success?
      files = Hotfolder::Hotfile.build_from_response(response)
      unless files.blank?
        Hotfolder.log "Hotfolder files in #{path}: #{logged(files)}"
      end
      files
    end

    private

    def browse_endpoint(endpoint)
      "#{endpoint}/files/browse"
    end

    def headers
      {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end

    def browse_body(path)
      {
        'path' => path,
        'sort' => 'mtime_d',
        'filters' => {}
      }.to_json
    end

    def basic_auth(username, password)
      {
        username: username,
        password: password
      }
    end

    def logged(array)
      array.map do |obj|
        "#{obj.basename} #{obj.mtime}"
      end.join(' --- ')
    end
  end
end
