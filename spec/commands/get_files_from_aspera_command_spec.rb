require 'spec_helper'

describe Hotfolder::GetFilesFromAsperaCommand do
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

    let(:endpoint) { 'fee' }
    let(:path)     { 'fi' }
    let(:username) { 'fo' }
    let(:password) { 'fum' }

    subject { described_class.execute(endpoint, path, username, password) }

    context 'returns items' do
      let(:fixture) { 'list_items.yml' }

      specify {
        expect(subject).to be_an(Array)
        expect(subject.first).to be_a(Hotfolder::Hotfile)
        expect(subject.first.basename).to eq 'JEOP5222.mxf'
        expect(subject.first.username).to eq 'fo'
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
