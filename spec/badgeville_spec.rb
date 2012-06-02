require 'spec_helper'

describe Badgeville do
  describe 'configure' do
    it 'configures the badgeville client' do
      Badgeville.configure({private_key: 'private_key'})

      Badgeville.client.should be_a(Badgeville::Client)
    end
  end

  describe 'client' do
    before(:each) do
      Badgeville.client = nil
    end

    it 'raises an error when no client was configured before' do
      expect {
        Badgeville.client
      }.to raise_error
    end

    it 'returns the configured client' do
      client = stub
      Badgeville::Client.stub(new: client)

      Badgeville.configure({private_key: 'private_key'})

      Badgeville.client.should == client
    end
  end

  describe 'client=' do
    it 'allows to overwrite the client' do
      client = stub

      Badgeville.client = client

      Badgeville.client.should == client
    end
  end
end