module Badgeville
  class RewardDefinition < Endpoint
    def self.find_by_site(site)
      response = client.get_all('reward_definitions.json', {site: site})
      response.inject([]) do |rewards, reward|
        rewards << Reward.new(reward)
      end
    end

    def self.update(id, attributes = {})
      client.put("/reward_definitions/#{id}.json", reward_definition: attributes)
    end

    def self.delete(id)
      client.delete("/reward_definitions/#{id}.json") != nil
    end
  end
end
