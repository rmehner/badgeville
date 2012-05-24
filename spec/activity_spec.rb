require 'spec_helper'

describe Badgeville::Activity do
  let(:activity_json) do
    {
      'verb'       => 'commented',
      'created_at' => '2011-08-18T22:55:03-07:00',
      'points'     => '30',
      'player_id'  => '28d96559be245bf658e9d90a3bca4d29',
      'user_id'    => 'f1c385726538d79e43795d6a4006e7fd',
      'rewards'    => [{'name' => 'first_comment'}, {'name' => 'first_share'}]
    }
  end

  describe 'initialize' do
    it 'lazy loads the rewards' do
      Badgeville::Reward.should_not_receive(:new)

      Badgeville::Activity.new(activity_json)
    end

    it 'sets some variables' do
      activity = Badgeville::Activity.new(activity_json)

      activity.verb.should      == 'commented'
      activity.points.should    == 30
      activity.player_id.should == '28d96559be245bf658e9d90a3bca4d29'
      activity.user_id.should   == 'f1c385726538d79e43795d6a4006e7fd'
    end
  end

  describe 'rewards' do
    it 'initializes and caches the rewards' do
      Badgeville::Reward.should_receive(:new).twice

      activity = Badgeville::Activity.new(activity_json)
      activity.rewards
      activity.rewards
    end

    it 'returns the rewards objects' do
      rewards = Badgeville::Activity.new(activity_json).rewards
      rewards.first.should be_a(Badgeville::Reward)
    end
  end

  describe 'created_at' do
    it 'returns the parsed date time of created at' do
      activity = Badgeville::Activity.new(activity_json)
      Time.parse(activity_json["created_at"]).iso8601
    end
  end

  describe 'meta' do
    it 'returns unknown attributes as meta data' do
      activity = Badgeville::Activity.new(activity_json.merge({'team' => 'myteam'}))

      activity.meta[:team].should == 'myteam'
    end

    it 'does not return known attributes as meta data' do
      activity = Badgeville::Activity.new(activity_json)

      activity.meta[:player_id].should be_nil
    end
  end
end
