require 'spec_helper'

describe Hotfolder::GetFilesCommand do
  describe '.execute' do
    before do
      allow(HTTParty)
        .to receive(:post)
        .and_return(response)
    end
    let(:response) { double(HTTParty::Response, success?: true, body: body) }
    let(:body) do
      hash = YAML.load_file("spec/fixtures/#{fixture}")
      hash.to_json
    end
    let(:fixture) { nil }

    subject { described_class.execute('fee', 'fi', 'fo', 'fum') }

    context 'returns items' do
      let(:fixture) { 'list_items.yml' }

      specify {
        expect(subject).to be_an(Array)
        expect(subject.first).to be_a(Hotfolder::Hotfile)
        expect(subject.first.basename).to eq 'JEOP5222.mxf'
      }
    end

    context 'not found' do
      let(:fixture) { 'list_items_no_such_directory.yml' }

      specify {
        expect(subject).to eq nil
      }
    end
  end
end
