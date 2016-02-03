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
end
