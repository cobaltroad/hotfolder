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
      let(:expected) do
        [
          {
            "path"=>"DMG Runner/Integration/JEOP5222.mxf",
            "basename"=>"JEOP5222.mxf",
            "type"=>"file",
            "size"=>37389884,
            "mtime"=>"2015-12-18T19:33:51Z",
            "permissions"=>[
              {"name"=>"view"},
              {"name"=>"edit"},
              {"name"=>"delete"}
            ]
          }
        ]
      end

      specify {
        expect(subject).to eq expected
      }
    end

    context 'not found' do
      let(:fixture) { 'list_items_no_such_directory.yml' }
      let(:expected) { nil }

      specify {
        expect(subject).to eq expected
      }
    end
  end
end
