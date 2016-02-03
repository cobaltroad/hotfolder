require 'spec_helper'

describe Hotfolder::GetInProgressCommand, :vcr do
  describe '.execute' do
    subject { described_class.execute 'runner' }

    it 'users runner client to get asset names' do
    end
  end
end
