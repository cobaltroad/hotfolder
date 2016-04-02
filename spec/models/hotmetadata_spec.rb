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
          category: 'migration_info',
          label: 'file_path',
          value: 'bar',
        }])
      end

      context 'given username' do
        let(:username) { 'foo' }

        specify do
          expect(subject[:custom_metadata_fields]).to eq([
            {
              category: 'migration_info',
              label: 'file_path',
              value: 'bar'
            },
            {
              category: 'migration_info',
              label: 'account_key',
              value: 'foo',
            }
          ])
        end

      end
    end
  end

end
