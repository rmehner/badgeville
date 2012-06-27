module Badgeville
  class Group < Endpoint
    ATTRIBUTES = [
      :id, :name, :type, :image_url, :tip, :message, :privileges, :note,
      :display_priority, :reward_image_url, :track_member, :adjustment,
      :units_possible
    ]

    ATTRIBUTES.each do |attr|
      attr_accessor attr
    end

    # everywhere else this is called "hint", try to get some consistency into the API
    alias_method :hint, :tip

    def self.find_by_site(site)
      response = client.get_all('groups.json', {site: site})

      response ? response.map {|group| new(group)} : []
    end

    def initialize(json = {})
      @json = json

      ATTRIBUTES.each do |attribute|
        send("#{attribute}=", @json[attribute.to_s])
      end
    end

    def rewards
      @rewards ||= @json['reward_definitions'].map do |reward_json|
        Reward.new(reward_json)
      end
    end

    def image_url(format = :original)
      @image_url.sub('original', format.to_s).sub(/^https?:/, '') if @image_url
    end
  end
end
