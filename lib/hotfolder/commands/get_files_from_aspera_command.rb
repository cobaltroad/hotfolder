module Hotfolder
  module GetFilesFromAsperaCommand
    extend self

    def execute(endpoint, path, username, password)
      response = AsperaClient::API.get_files(endpoint, basic_auth(username, password), path)
      raise 'Error retrieving hotfolder files' unless response.success?
      files = Hotfolder::Hotfile.build_from_response(response)
      unless files.blank?
        Hotfolder.log "Hotfolder files in #{path}: #{logged(files)}"
      end
      files
    end

    private

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
