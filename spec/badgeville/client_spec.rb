require 'spec_helper'

describe Badgeville::Client do
  before(:each) do
    Badgeville.configure(private_key: 'API_KEY')
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

    it 'raises a Badgeville::Unprocessable if Badgeville responds with 422' do
      stubbed_request.to_return(status: 422, body: '{{"limit":["exceeded"]}')

      expect {
        Badgeville.client.get('/rewards.json')
      }.to raise_error Badgeville::Unprocessable
    end
  end

  describe 'delete' do
    it 'sends a DELETE request to the given endpoint' do
      stub_request(:delete, /.*/)

      Badgeville.client.delete('/endpoint.json')

      a_request(:delete, /\/endpoint\.json/).should have_been_made
    end

    it 'forwards to remove_reward if the argument is a reward' do
      stub_request(:delete, /.*/).to_return(status: 200)

      reward = Badgeville::Reward.new(
        'created_at' => '2011-08-18T22:55:03-07:00',
        'id'         => 'REWARD_ID',
        'user_id'    => 'USER_ID'
      )

      Badgeville.client.delete(reward)

      a_request(:delete, /\/rewards\/REWARD_ID.json/).should have_been_made
    end
  end
end
