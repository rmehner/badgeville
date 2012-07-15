require 'spec_helper'

describe Badgeville do
  describe '.configure' do
    context 'using an options hash as argument' do
      it 'configures the badgeville client' do
        Badgeville.configure(private_key: 'private_key')

        Badgeville.client.should be_a(Badgeville::Client)
        Badgeville.client.private_key.should == 'private_key'
      end

      it 'sets default values for `timeout`, `host` and `protocol` if not set' do
        Badgeville.configure(private_key: 'private_key')

        Badgeville.client.timeout.should == 5
        Badgeville.client.protocol.should == 'https'
        Badgeville.client.host.should == 'sandbox.v2.badgeville.com'
      end
    end

    context 'getting passed a block' do
      it 'configures the badgeville client' do
        Badgeville.configure do |config|
          config.private_key = 'private_key'
          config.per_page = 5
        end

        Badgeville.client.should be_a(Badgeville::Client)
        Badgeville.client.private_key.should == 'private_key'
        Badgeville.client.per_page.should == 5
      end

      it 'sets default values for `timeout`, `host` and `protocol` if not set' do
        Badgeville.configure do |config|
          config.private_key = 'private_key'
        end

        Badgeville.client.timeout.should == 5
        Badgeville.client.protocol.should == 'https'
        Badgeville.client.host.should == 'sandbox.v2.badgeville.com'
      end
    end
  end

  describe '.client' do
    before(:each) do
      Badgeville.client = nil
    end

    it 'raises an error when no client was configured before' do
      expect {
        Badgeville.client
      }.to raise_error
    end
  end

  describe '.client=' do
    it 'allows to overwrite the client' do
      client = stub

      Badgeville.client = client

      Badgeville.client.should == client
    end
  end
end
