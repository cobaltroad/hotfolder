require 'spec_helper'

describe Hotfolder do
  context 'no hotfolder_ingest_type' do
    let(:test_class) { Class.new }
    before do
      test_class.send :include, Hotfolder
    end

    specify {
      expect { test_class.new }.to raise_error "hotfolder_ingest_type is not set"
    }
  end

  context 'invalid hotfolder_ingest_type' do
    let(:test_class) { Class.new }
    before do
      test_class.send :include, Hotfolder
      test_class.send :hotfolder_ingest_type, "foo"
    end

    specify {
      expect { test_class.new }.to raise_error "hotfolder_ingest_type is invalid"
    }
  end

  context 'valid hotfolder_ingest_type' do
    let(:test_class) { Class.new }
    before do
      test_class.send :include, Hotfolder
      test_class.send :hotfolder_ingest_type, "runner"
    end
    let(:test_instance) { test_class.new }

    context '.in_progress', :vcr do
      subject { test_instance.ingest_type }

      it 'users runner client to get asset names' do
        expect(subject).to eq 'runner'
      end
    end
  end

  context 'calls appropriate methods' do
    let(:test_class) { Class.new }
    let(:hotfile_hash) {{
      'path'     => 'path',
      'basename' => 'basename',
      'size'     => '123456',
      'mtime'    => '2016-01-01T13:14:15Z'
    }}
    let(:username) { 'foo' }
    let(:hotfile1)   { Hotfolder::Hotfile.new(hotfile_hash, username) }
    let(:hotfile2)   { Hotfolder::Hotfile.new(hotfile_hash, username) }
    let(:hotfile3)   { Hotfolder::Hotfile.new(hotfile_hash, username) }
    let(:hotfile4)   { Hotfolder::Hotfile.new(hotfile_hash, username) }
    let(:hotfiles)   {[
      hotfile1,
      hotfile2,
      hotfile3,
      hotfile4,
    ]}

    def stub_hotfile_methods_for(hotfile)
      allow(hotfile).to receive(:ready?).and_return true
      allow(hotfile).to receive(:build_metadata_using)
    end

    before do
      test_class.send :include, Hotfolder
      test_class.send :hotfolder_ingest_type, "runner"
      test_class.send :define_method, :upload_files, ->() do
        Array.new
        super()
      end

      allow(Array).to receive(:new)
      allow(Hotfolder::CreateFilesCommand).to receive(:execute)
      allow(Hotfolder::GetInProgressCommand)
        .to receive(:execute)
        .and_return([])
      allow(Hotfolder::GetFilesFromAsperaCommand)
        .to receive(:execute)
        .and_return(hotfiles)
      hotfiles.each do |hf|
        stub_hotfile_methods_for(hf)
      end
    end
    let(:test_instance) { test_class.new }

    it 'executes the appropriate commands' do
      test_instance.consume!
      expect(Hotfolder::GetInProgressCommand).to have_received(:execute)
      expect(Hotfolder::GetFilesFromAsperaCommand).to have_received(:execute)
      expect(Array).to have_received(:new)
      expect(Hotfolder::CreateFilesCommand).to have_received(:execute).exactly(4).times
    end

    context 'error while building metadata' do
      before do
        allow(hotfiles.last)
          .to receive(:build_metadata_using)
          .and_raise
      end

      it 'leaves the errored file alone' do
        test_instance.consume!
        expect(Hotfolder::CreateFilesCommand).to have_received(:execute).exactly(3).times
      end
    end
  end

  context 'loads a config file' do
    before do
      require_relative 'fixtures/example/example'
      require_relative 'fixtures/example/example_metadata'
    end
    let(:config) do
      root = File.dirname(__FILE__)
      path = File.join(root, "fixtures/example/example.yml")
      YAML.load_file(path)["test"]
    end
    subject { Example.config(config).new }

    it 'reads the config file from a default location' do
      expect(subject.name).to eq 'Example Config'
    end

    context 'file pickup delay' do
      let(:config) do
        {
          name: "File Pickup Config",
          class_name: "Example"
        }
      end

      context 'only hours is present' do
        before do
          config.merge!(file_pickup_delay_hours: 1)
        end

        it 'parses the delay into seconds' do
          expect(subject.file_pickup_delay).to eq 3600
        end
      end

      context 'hours and minutes' do
        before do
          config.merge!(
            file_pickup_delay_hours: 1,
            file_pickup_delay_minutes: 30
          )
        end

        it 'uses the maximum delay' do
          expect(subject.file_pickup_delay).to eq 3600
        end
      end

      context 'hours and minutes and seconds' do
        before do
          config.merge!(
            file_pickup_delay_hours: 1,
            file_pickup_delay_minutes: 30,
            file_pickup_delay_seconds: 600
          )
        end

        it 'uses the maximum delay' do
          expect(subject.file_pickup_delay).to eq 3600
        end
      end

      context 'only minutes' do
        before do
          config.merge!(file_pickup_delay_minutes: 60)
        end

        it 'parses the delay into seconds' do
          expect(subject.file_pickup_delay).to eq 3600
        end
      end

      context 'minutes and seconds' do
        before do
          config.merge!(
            file_pickup_delay_minutes: 60,
            file_pickup_delay_seconds: 600
          )
        end

        it 'uses the maximum delay' do
          expect(subject.file_pickup_delay).to eq 3600
        end
      end

      context 'only seconds' do
        before do
          config.merge!(file_pickup_delay_seconds: 60)
        end

        it 'parses the delay into seconds' do
          expect(subject.file_pickup_delay).to eq 60
        end
      end
    end
  end
end
