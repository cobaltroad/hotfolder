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
  let(:instance) { described_class.new hash }

  describe '.new' do
    subject { instance }

    specify {
      expect(subject.path).to     eq 'foo/bar'
      expect(subject.basename).to eq 'ABCD1234@.MXF'
      expect(subject.size).to     eq '123456'
      expect(subject.mtime).to    eq Time.parse('2016-01-01T13:14:15Z')
      expect(subject.metadata).to eq nil
    }
  end

  describe '.ready?' do
    before do
      allow_any_instance_of(described_class)
        .to receive(:now)
        .and_return now
    end
    subject { instance.ready?(24) }

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
    subject { instance.build_metadata_using(test_class) }

    context 'test class inherits from Hotmetadata' do
      let(:test_class) { Class.new(Hotfolder::Hotmetadata) }

      context 'on_initialize defined' do
        before do
          test_class.send :define_method, :on_initialize, ->(does_nothing) {
            @gpms_ids = ['foo']
          }
        end
        specify { expect(subject.gpms_ids).to eq ['foo'] }
      end

      context 'on_initialize not defined' do
        specify { expect(subject.gpms_ids).to eq nil }
      end
    end

    context 'test class does not inherit from Hotmetadata' do
      let(:test_class) { Class.new }

      context 'initialize defined correctly' do
        before do
          test_class.send :define_method, :initialize, ->(does_nothing) {}
          test_class.send :define_method, :runner_object, ->() {}
        end

        specify {
          subject
          expect(instance.metadata).to be_a(test_class)
          expect(instance.metadata.respond_to?(:runner_object)).to be true
        }
      end

      context 'initialize not defined correctly' do
        before do
          test_class.send :define_method, :initialize, ->() {}
        end

        specify {
          expect {
            subject
          }.to raise_error(Hotfolder::HotfolderError)
        }
      end

      context 'initialize not defined at all' do
        specify {
          expect {
            subject
          }.to raise_error(Hotfolder::HotfolderError)
        }
      end
    end
  end
end
