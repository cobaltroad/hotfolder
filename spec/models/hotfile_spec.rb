require 'spec_helper'

describe Hotfolder::Hotfile do
  let(:basename) { 'ABCD1234@.MXF' }
  let(:hash) do
    {
      'path'     => 'foo/bar',
      'basename' => basename,
      'size'     => '123456',
      'mtime'    => '2016-01-01T13:14:15Z'
    }
  end
  let(:username) { 'goku' }
  let(:instance) { described_class.new(hash, username) }

  describe '.new' do
    subject { instance }

    specify {
      expect(subject.path).to     eq 'foo/bar'
      expect(subject.basename).to eq 'ABCD1234@.MXF'
      expect(subject.size).to     eq '123456'
      expect(subject.mtime).to    eq Time.parse('2016-01-01T13:14:15Z')
      expect(subject.metadata).to eq nil
      expect(subject.username).to eq 'goku'
    }
  end

  describe '.ready?' do
    before do
      allow_any_instance_of(described_class)
        .to receive(:now)
        .and_return now
    end
    subject { instance.ready?(86400) }

    context 'newer' do
      let(:now) { Time.parse('2016-01-01T14:00:00Z').to_i }

      specify { expect(subject).to eq false }
    end

    context 'older' do
      let(:now) { Time.parse('2016-02-01T12:00:00Z').to_i }

      specify { expect(subject).to eq true }
    end
  end

  describe '.build_metadata_using' do
    subject { instance.build_metadata_using(test_class_config) }

    context 'metadatda class name is not specified' do
      let(:test_class_config) do
        {
          folder_ids: [123]
        }
      end

      specify { expect(subject).to be_a(Hotfolder::Hotmetadata) }
      specify { expect(subject.folder_ids).to eq [123] }
    end

    context 'metadata class name inherits from hotmetadata' do
      let(:test_class_config) do
        {
          class_name: test_class.name,
          folder_ids: [456]
        }
      end

      context 'multiple files ingested at once' do
        let(:test_class) { TestClassMultiple = Class.new(Hotfolder::Hotmetadata) }
        let(:first) { instance.build_metadata_using(test_class_config) }

        it 'maintains the metadata class for both instances' do
          expect(first).to be_a(TestClassMultiple)
          expect(subject).to be_a(TestClassMultiple)
        end
      end
      context 'on_initialize defined' do
        let(:test_class) { TestClass1 = Class.new(Hotfolder::Hotmetadata) }
        before do
          test_class.send :define_method, :on_initialize, ->(file, config) {
            @gpms_ids   = ['foo']
          }
        end

        it 'relies on the defined method' do
          expect(subject).to be_a(TestClass1)
          expect(subject.gpms_ids).to eq ['foo']
          expect(subject.folder_ids).to eq nil
        end
      end

      context 'on initialize not defined' do
        let(:test_class) { TestClass2 = Class.new(Hotfolder::Hotmetadata) }

        it 'relies on the passed config' do
          expect(subject).to be_a(TestClass2)
          expect(subject.gpms_ids).to eq nil
          expect(subject.folder_ids).to eq [456]
        end
      end
    end
  end
end
