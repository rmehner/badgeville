module Badgeville
  class Client
    TIMEOUT_SECS = 3
    HOST         = 'sandbox.v2.badgeville.com'
    PROTOCOL     = 'https'

    attr_accessor :timeout, :debug

    include Helpers
    include DeprecatedClientMethods

    def initialize(email, opts = {})
      # Required Parameters
      @site        = opts['site']
      @private_key = opts['private_key']
      @public_key  = opts['public_key']
      @timeout     = opts['timeout'] || TIMEOUT_SECS
      @host        = opts['host'] || HOST
      @protocol    = opts['protocol'] || PROTOCOL
      @user        = email
      @per_page    = opts['per_page']
    end

    def debug=(flag)
      log_file       = flag ? "stdout" : nil
      RestClient.log = log_file
      @debug         = flag
    end

    def get(endpoint, params = {})
      begin
        response = session[endpoint].get(params: params)
        JSON.parse(response)['data']
      rescue RestClient::ResourceNotFound => e
        nil
      end
    end

    def post(endpoint, body = {})
      response = session[endpoint].post(body.to_json, content_type: :json, accept: :json)
      JSON.parse(response)
    end

    def put(endpoint, body = {})
      session[endpoint].put(body.to_json, content_type: :json)
    end

    private

      def session
        if @session.nil?
          base_url = "#{@protocol}://#{@host}/api/berlin/#{@private_key}"
          @session = RestClient::Resource.new base_url,
            :timeout => @timeout, :open_timeout => @timeout
        end
        @session
      end
  end
end
