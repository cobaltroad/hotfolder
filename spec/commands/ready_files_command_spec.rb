require 'spec_helper'

describe Hotfolder::ReadyFilesCommand do
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
    let(:new_files) { Hotfolder::Hotfile.build_from_response(response) }
    let(:delay_hours) { 24 }
    let(:limit) { 10 }

    let(:subject) { described_class.execute(new_files, delay_hours, limit) }

    context 'too soon for some files' do
      let(:now) { Time.parse('2016-02-09T23:00:00Z').to_i }

      specify { expect(subject.length).to eq 6 }
    end
    
    context 'late enough for all files' do
      let(:now) { Time.parse('2016-02-11T23:00:00Z').to_i }

      specify { expect(subject.length).to eq 8 }

      context 'limit is less than all files' do
        let(:limit) { 5 }

        specify { expect(subject.length).to eq limit }
      end
    end
  end
end
