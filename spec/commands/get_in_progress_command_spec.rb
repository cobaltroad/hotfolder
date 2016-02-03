require 'spec_helper'

describe Hotfolder::GetInProgressCommand, :vcr do
  describe '.execute' do
    subject { described_class.execute 'runner' }

    it 'users runner client to get asset names' do
      expect(subject).to eq [
        "2170339-52469-189308-Rabble1jpg-620x.jpg",
        "pumapants.jpg",
        "aliens.jpg"
      ]
    end
  end
end
