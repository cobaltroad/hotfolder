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

  describe '.upload!' do
    before do
      instance.upload!
    end

    context 'no revision' do
      specify {
        expect(instance.metadata).to be_a(Hotfolder::Hotmetadata)
        expect(instance.slug).to eq 'ABCD1234'
        expect(instance.revision).to eq 0
      }
    end

    context 'revision but no number' do
      let(:basename) { 'ABCD1234rev@.MXF' }

      specify { expect(instance.revision).to eq 1 }
    end

    context 'revision and number' do
      let(:basename) { 'ABCD123rev3@.MXF' }

      specify { expect(instance.revision).to eq 3 }
    end

    context 'unknown file name parse' do
      let(:basename) { 'SOME_OTHER_FILE.jpg' }

      specify { expect(instance.slug).to eq '' }
    end
  end
end
