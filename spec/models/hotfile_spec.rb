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
    let(:test_class) { Class.new }
    before do
      test_class.send :define_method, :initialize, ->(does_nothing) {}
    end

    subject { instance.build_metadata_using(test_class) }

    specify {
      subject
      expect(instance.metadata).to be_a(test_class)
    }
  end
end
