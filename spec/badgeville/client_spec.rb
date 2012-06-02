require 'spec_helper'

describe Badgeville::Client do
  before(:each) do
    Badgeville.configure(private_api_key: 'API_KEY')
  end

  describe 'request!' do
    let(:stubbed_request) { stub_request(:any, /.*/) }

    it 'raises a Badgeville::NotAvailable error when a request timeouts' do
      stubbed_request.to_timeout

      expect {
        Badgeville.client.get('/rewards.json')
      }.to raise_error Badgeville::NotAvailable
    end

    it 'raises a Badgeville::NotFound error when a request is returned with 404' do
      stubbed_request.to_return(status: 404)

      expect {
        Badgeville.client.get('/rewards.json')
      }.to raise_error Badgeville::NotFound
    end

    it 'raises a Badgeville::ServerError if Badgeville returns 500' do
      stubbed_request.to_return(status: 500)

      expect {
        Badgeville.client.get('/rewards.json')
      }.to raise_error Badgeville::ServerError
    end

    it 'raises a Badgeville::ParseError if Badgeville returns invalid json' do
      stubbed_request.to_return(status: 200, body: '{invalid_json}')

      expect {
        Badgeville.client.get('/rewards.json')
      }.to raise_error Badgeville::ParseError
    end

    it 'raises a Badgeville::Forbidden if Badgeville responds with 403' do
      stubbed_request.to_return(status: 403, body: '{{"errors":[{"error":"access denied"}]}')

      expect {
        Badgeville.client.get('/rewards.json')
      }.to raise_error Badgeville::Forbidden
    end
  end
end