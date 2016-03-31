require 'spec_helper'

describe Hotfolder::GetReadyFilesCommand do
  describe '.execute' do
    before do
      allow_any_instance_of(Hotfolder::Hotfile)
        .to receive(:now)
        .and_return now
    end
    let(:body) do
      hash = YAML.load_file("spec/fixtures/get_valid_files.yml")
      hash.to_json
    end
    let(:response) { double('HTTP response', body: body) }
    let(:username) { 'goku' }
    let(:new_files) { Hotfolder::Hotfile.build_from_response(response, username) }
    let(:delay_seconds) { 86400 }

    let(:subject) { described_class.execute(new_files, delay_seconds) }

    context 'too soon for some files' do
      let(:now) { Time.parse('2016-02-09T23:00:00Z').to_i }

      specify { expect(subject.length).to eq 6 }
    end

    context 'late enough for all files' do
      let(:now) { Time.parse('2016-02-11T23:00:00Z').to_i }

      specify { expect(subject.length).to eq 8 }
    end
  end
end
