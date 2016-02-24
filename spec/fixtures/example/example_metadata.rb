class ExampleMetadata < Hotfolder::Hotmetadata
  attr_accessor :slug
  attr_accessor :revision
  attr_accessor :gpms_ids
  attr_accessor :folder_ids

  MAPPING = {
    'WOF' => {
      folder_business_key: 'WOF Archive',
      show_number_prefix: 'S-',
      gpms_id: 744445
    },
    'JEOP' => {
      folder_business_key: 'Jeopardy! Archive',
      show_number_prefix: '',
      gpms_id: 774056
    }
  }

  def on_initialize(file, options={})
    filename = file.basename
    series, show_number, rev, rev_number = filename_regex_match(filename)

    @slug           = "#{series}#{show_number}"
    revision_number = rev_number.blank? ? 1 : rev_number.to_i
    @revision       = rev.blank?        ? 0 : revision_number

    mapped_series = MAPPING[series]
    if mapped_series
      mapped_show_number = "#{mapped_series[:show_number_prefix]}#{show_number}"

      @gpms_ids   = [get_show_gpms_id(mapped_series[:gpms_id], mapped_show_number)]
      @folder_ids = [get_folder_id(mapped_series[:folder_business_key])]
    end
  end

  private

  def filename_regex_match(basename)
    /([a-z]+)(\d+)(|rev)(\d*)@.(?:mxf)/i.match(basename).try(:captures)
  end

  def get_show_gpms_id(series_gpms_id, show_number)
    response = RunnerClient::API.get_title_by_parent_gpms_id_and_show_number(series_gpms_id, show_number)
    return response.title.gpms_id if response.success?
  end

  def get_folder_id(business_key)
    escaped_key = CGI.escape(business_key)
    response = RunnerClient::API.get_folder_id_by_business_key(escaped_key)
    response['folder_id']
  end
end
