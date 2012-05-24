module Badgeville
  class Reward
    attr_accessor :active, :definition_id, :hint, :id, :message, :name, :tags
    attr_accessor :threshold, :verb

    attr_writer :image_url

    def initialize(json = {})
      @json = json

      if @json
        reward_definition = @json['definition']
        reward_definition ? init_from(reward_definition) : init_from(@json)
        @id = json['id'] if @json.has_key?('user_id')
      end
    end

    def earned_at
      if @json.has_key?('user_id') && !@earned_at
        @earned_at = DateTime.parse(@json['created_at']).to_time
      end

      @earned_at
    end

    def image_url(format = :original)
      @image_url.sub('original', format.to_s).sub(/^https?:/, '') if @image_url
    end

    private

      def init_from(json)
        ['name', 'active', 'hint', 'image_url', 'message'].each do |key|
          send("#{key}=", json[key])
        end

        @id = @definition_id = json['_id']

        if json['data'] && json['type'] == 'achievement'
          @verb      = json['data']['verb']
          @threshold = json['data']['threshold'].to_i
        end

        @tags = json['tags'] || []
      end
  end
end
