require 'spec_helper'

describe 'Badgeville Errors' do
  before(:each) do
    Badgeville.configure(private_key: 'API_KEY')
  end

  let(:stubbed_request) {stub_request(:any, /.*/)}

  describe 'deprecated BadgevilleError' do
    it 'should have code and data attributes' do
      badgeville_error = Badgeville::BadgevilleError.new(404, 'Not Found')

      badgeville_error.data.should == 'Not Found'
      badgeville_error.code.should == 404
    end
  end

  describe Badgeville::Error do
    it 'should have an original_error and message attribute' do
      error = Badgeville::Error.new('runtime error', RuntimeError.new)

      error.original_error.class.should == RuntimeError
      error.message.should == '[Badgeville] runtime error'
    end
  end

  describe Badgeville::Forbidden do
    it 'should have an original_error and message attribute' do
      stubbed_request.to_return(status: 403)

      begin
        Badgeville.client.get('/rewards.json')
      rescue Badgeville::Forbidden => e
        e.message.should == '[Badgeville] Access denied'
        e.original_error.class.should == RestClient::Forbidden
      end
    end

    it 'should have a response attribute' do
      response = '{{"errors":[{"error":"access denied"}]}'
      stubbed_request.to_return(status: 403, body: response)

      begin
        Badgeville.client.get('/rewards.json')
      rescue Badgeville::Forbidden => e
        e.response.should == response
      end
    end
  end

  describe Badgeville::ServerError do
    it 'should have an original_error and message attribute' do
      stubbed_request.to_return(status: 500)

      begin
        Badgeville.client.get('/rewards.json')
      rescue Badgeville::ServerError => e
        e.message.should == '[Badgeville] Internal server error'
        e.original_error.class.should == RestClient::InternalServerError
      end
    end

    it 'should have a response attribute' do
      response = '{{"errors":[{"error":"Sorry, something went wrong"}]}'
      stubbed_request.to_return(status: 500, body: response)

      begin
        Badgeville.client.get('/rewards.json')
      rescue Badgeville::ServerError => e
        e.response.should == response
      end
    end
  end

  describe Badgeville::NotAvailable do
    it 'should have an original_error and message attribute' do
      stubbed_request.to_timeout

      begin
        Badgeville.client.get('/rewards.json')
      rescue Badgeville::NotAvailable => e
        e.message.should == '[Badgeville] Service is currently not available'
        e.original_error.class.should == RestClient::RequestTimeout
      end
    end
  end

  describe Badgeville::NotFound do
    it 'should have an original_error and message attribute' do
      stubbed_request.to_return(status: 404)

      begin
        Badgeville.client.get('/rewards.json')
      rescue Badgeville::NotFound => e
        e.message.should == '[Badgeville] Could not find resource'
        e.original_error.class.should == RestClient::ResourceNotFound
      end
    end

    it 'should have a response attribute' do
      response = '{{"errors":[{"error":"resource could not be found"}]}'
      stubbed_request.to_return(status: 404, body: response)

      begin
        Badgeville.client.get('/rewards.json')
      rescue Badgeville::NotFound => e
        e.response.should == response
      end
    end
  end

  describe Badgeville::Unprocessable do
    it 'should have an original_error and message attribute' do
      stubbed_request.to_return(status: 422)

      begin
        Badgeville.client.get('/rewards.json')
      rescue Badgeville::Unprocessable => e
        e.message.should == '[Badgeville] Unprocessable entity'
        e.original_error.class.should == RestClient::UnprocessableEntity
      end
    end

    it 'should have a response attribute' do
      response = '{"limit":["exceeded"]}'
      stubbed_request.to_return(status: 422, body: response)

      begin
        Badgeville.client.get('/rewards.json')
      rescue Badgeville::Unprocessable => e
        e.response.should == response
      end
    end
  end

  describe Badgeville::ParseError do
    it 'should have an original_error and message attribute' do
      response = '{invalidjson}'
      stubbed_request.to_return(status: 200, body: response)

      begin
        Badgeville.client.get('/rewards.json')
      rescue Badgeville::ParseError => e
        e.message.should match(/unexpected token at/)
        e.original_error.class.should == JSON::ParserError
      end
    end
  end
end
