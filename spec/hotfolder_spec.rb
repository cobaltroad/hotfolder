require 'spec_helper'

describe Hotfolder do
  context 'no hotfolder_ingest_type' do
    class BadClass1
      include Hotfolder
    end

    specify {
      expect { BadClass1.new }.to raise_error "hotfolder_ingest_type is not set"
    }
  end

  context 'invalid hotfolder_ingest_type' do
    class BadClass2
      include Hotfolder

      hotfolder_ingest_type "foo"
    end

    specify {
      expect { BadClass2.new }.to raise_error "hotfolder_ingest_type is invalid"
    }
  end

  context 'valid hotfolder_ingest_type' do
    class TestClass
      include Hotfolder

      hotfolder_ingest_type 'runner'
    end
    let(:test_instance) { TestClass.new }

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
    end
    let(:config) do
      root = File.dirname(__FILE__)
      path = File.join(root, "fixtures/example/example.yml")
      YAML.load_file(path)["test"]
    end
    let(:test_instance) { Example.config(config).new }
    subject { test_instance.source_file_path }

    it 'reads the config file from a default location' do
      expect(subject).to eq './Some Directory/Path'
    end
  end
end
