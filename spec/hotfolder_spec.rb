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
          class_name: "Example",
          metadata_class_name: "ExampleMetadata"
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
