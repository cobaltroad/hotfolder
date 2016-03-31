require 'spec_helper'

describe Hotfolder::Hotmetadata do
  let(:instance) { described_class.new file }
  let(:file)     { double(Hotfolder::Hotfile,
                          :basename => name,
                          :username => username,
                          :path => path) }
  let(:name)     { nil }
  let(:path)     { nil }
  let(:username) { nil }

  describe '.runner_object' do
    subject { instance.runner_object }

    context 'given file path' do
      let(:path) { 'bar' }

      specify do
        expect(subject[:custom_metadata_fields]).to eq([{
          category: 'hotfolder_source_path',
          label: 'file_path',
          value: path,
        }])
      end

      context 'given username' do
        let(:username) { 'foo' }

        specify do
          expect(subject[:custom_metadata_fields]).to eq([
            {
              category: 'hotfolder_source_path',
              label: 'file_path',
              value: 'bar'
            },
            {
              category: 'hotfolder_account_key',
              label: 'account_key',
              value: username,
            }
          ])
        end

      end
    end
  end

end
