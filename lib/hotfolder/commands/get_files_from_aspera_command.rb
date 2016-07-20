module Hotfolder
  module GetFilesFromAsperaCommand
    extend self

    def execute(endpoint, path, username, password)
      response = AsperaClient::API.get_files(endpoint, basic_auth(username, password), path)
      if !response.success? or response['error'].present?
        error = response['error'] || "invalid username or password '#{username}'"
        raise "Error retrieving files: #{error}, path: #{path}"
      end
      files = Hotfolder::Hotfile.build_from_response(response, username)
      unless files.blank?
        Hotfolder.logger.try(:info, "#{path}: #{logged(files)}")
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
        "#{obj.basename} (#{obj.mtime})"
      end
    end
  end
end
