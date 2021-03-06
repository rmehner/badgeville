module Badgeville
  class Client
    TIMEOUT_SECS = 5
    HOST         = 'sandbox.v2.badgeville.com'
    PROTOCOL     = 'https'

    attr_accessor :private_key, :per_page
    attr_writer   :timeout, :host, :protocol

    include DeprecatedClientMethods

    def initialize(email, opts = {})
      @user = email

      opts.each do |option, value|
        send("#{option}=", value)
      end
    end

    def timeout
      @timeout ||= TIMEOUT_SECS
    end

    def protocol
      @protocol ||= PROTOCOL
    end

    def host
      @host ||= HOST
    end

    def get(endpoint, params = {})
      response = request!(:get, endpoint, params)
      response ? response['data'] : nil
    end

    def get_all(endpoint, params = {})
      data              = []
      current_page      = 1
      total_pages       = nil
      params[:per_page] = 50

      while total_pages.nil? || current_page <= total_pages
        params[:include_totals] = true unless total_pages
        response = request!(:get, endpoint, params.merge(page: current_page))

        data << response['data']

        if response['paging']
          current_page = response['paging']['current_page'].to_i + 1
          total_pages  = response['paging']['total_pages'].to_i if total_pages.nil?
        else
          total_pages = 0
        end
      end

      data.flatten
    end

    def post(endpoint, params = {})
      request!(:post, endpoint, params)
    end

    def put(endpoint, params = {})
      request!(:put, endpoint, params)
    end

    def delete(endpoint)
      if endpoint.is_a?(Reward)
        warn '[DEPRECATED] Please use Badgeville::Client.remove_reward instead'
        return remove_reward(endpoint)
      end

      begin
        request!(:delete, endpoint)
      rescue NotFound
        nil
      end
    end

    private

      def request!(method, endpoint, params = {})
        begin
          if method == :get
            response = session[endpoint].get(params: params)
          elsif method == :delete
            response = session[endpoint].delete
          else
            response = session[endpoint].send(method, params.to_json, content_type: :json, accept: :json)
          end

          response.length == 0 ? nil : JSON.parse(response)
        rescue RestClient::RequestTimeout => e
          raise NotAvailable.new(e)
        rescue RestClient::ResourceNotFound => e
          raise NotFound.new(e)
        rescue RestClient::InternalServerError => e
          raise ServerError.new(e)
        rescue RestClient::Forbidden => e
          raise Forbidden.new(e)
        rescue RestClient::UnprocessableEntity => e
          raise Unprocessable.new(e)
        rescue JSON::ParserError => e
          raise ParseError.new(e)
        end
      end

      def session
        unless @session
          base_url = "#{protocol}://#{host}/api/berlin/#{private_key}"
          @session = RestClient::Resource.new(
            base_url,
            timeout: timeout,
            open_timeout: timeout
          )
        end
        @session
      end
  end
end
