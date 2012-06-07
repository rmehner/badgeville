require 'spec_helper'

describe Badgeville::User do
  before(:each) do
    Badgeville.configure(private_key: 'private_key')
  end

  let(:user_json) do
    {
      'data' => {
        'name'       => 'Demo User',
        'created_at' => '2012-04-07T13:50:11-07:00',
        'email'      => 'user@example.org',
        '_id'        => '321f5a96dcd1ef5de8fd9b81c7c70272'
      }
    }
  end

  describe '.find' do
    before(:each) do
      stub_request(:get, /.*\/users\/USER_ID\.json/).to_return(
        status: 200,
        body: user_json.to_json
      )
    end

    it 'gets the user from badgeville' do
      Badgeville::User.find('USER_ID')

      a_request(:get, /.*\/users\/USER_ID\.json/).should have_been_made
    end

    it 'returns the user object' do
      user = Badgeville::User.find('USER_ID')

      user.should be_a(Badgeville::User)
      user.id.should == '321f5a96dcd1ef5de8fd9b81c7c70272'
    end

    it 'returns nil if the user could not be found' do
      stub_request(:get, /.*\/users\/DOES_NOT_EXIST\.json$/).to_return(
        status: 404
      )

      Badgeville::User.find('DOES_NOT_EXIST').should be_nil
    end
  end

  describe '.create' do
    before(:each) do
      stub_request(:post, /.*\/users\.json$/).to_return(
        status: 201,
        body: user_json['data'].to_json
      )
    end

    it 'creates the user at badgeville' do
      Badgeville::User.create(name: 'rmehner', email: 'rmehner@example.org')

      a_request(:post, /.*\/users\.json$/).with(
        body: {user: {email: 'rmehner@example.org', name: 'rmehner'}},
        headers: {'Content-Type' => 'application/json'}
      ).should have_been_made
    end

    it 'returns the created user' do
      user = Badgeville::User.create(name: 'rmehner', email: 'rmehner@example.org')

      user.should be_a(Badgeville::User)
      user.id.should == '321f5a96dcd1ef5de8fd9b81c7c70272'
    end
  end

  describe '.delete' do
    it 'deletes the user at badgeville' do
      stub_request(:delete, /.*\/users\/USER_ID\.json/).to_return(
        status: 200, body: {}
      )

      Badgeville::User.delete('USER_ID')

      a_request(:delete, /.*\/users\/USER_ID\.json/).should have_been_made
    end

    it 'returns nil if the user could not be found' do
      stub_request(:delete, /.*\/users\/USER_ID\.json/).to_return(
        status: 404, body: {"errors" => [{"error" => "not found"}]}
      )

      Badgeville::User.delete('USER_ID').should be_nil
    end
  end

  describe 'initialize' do
    it 'sets the attributes' do
      user = Badgeville::User.new(user_json['data'])

      user.id.should == '321f5a96dcd1ef5de8fd9b81c7c70272'
      user.email.should == 'user@example.org'
      user.name.should == 'Demo User'
    end
  end

  describe 'created_at' do
    it 'returns created_at as Time' do
      user = Badgeville::User.new(user_json['data'])

      user.created_at.iso8601.should == Time.parse(user_json['data']['created_at']).iso8601
    end
  end
end
