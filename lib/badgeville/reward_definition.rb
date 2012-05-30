module Badgeville
  class RewardDefinition < Endpoint
    def self.find_by_site(site)
      response = client.get_all('reward_definitions.json', {site: site})
      response.inject([]) do |rewards, reward|
        rewards << Reward.new(reward)
      end
    end
  end
end
