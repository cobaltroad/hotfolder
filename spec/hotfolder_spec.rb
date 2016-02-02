require 'spec_helper'

describe Hotfolder do
  context 'no hotfolder_ingest_type' do
    class TestClass
      include Hotfolder
    end

    specify {
      expect { TestClass.new }.to raise_error "hotfolder_ingest_type is not set"
    }
  end

  context 'invalid hotfolder_ingest_type' do
    class TestClass2
      include Hotfolder

      hotfolder_ingest_type "foo"
    end

    specify {
      expect { TestClass2.new }.to raise_error "hotfolder_ingest_type is invalid"
    }
  end
end
