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
    let(:test_instance) { Example.config(config).new }
    subject { test_instance.name }

    it 'reads the config file from a default location' do
      expect(subject).to eq 'Example Config'
    end
  end
end
