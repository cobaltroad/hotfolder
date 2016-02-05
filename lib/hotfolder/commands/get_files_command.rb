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
      files = JSON.parse(response.body)['items']
      unless files.blank?
        Hotfolder.log "Hotfolder asset names: #{logged(files)}"
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
        'sort' => 'size_d',
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
        {
          name: obj['basename'],
          mtime: obj['mtime']
        }
      end
    end
  end
end
