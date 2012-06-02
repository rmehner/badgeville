require 'spec_helper'

describe Badgeville::Activity do
  before(:each) do
    Badgeville.configure(private_key: 'private_key')
  end

  let(:activity_json) do
    {
      'verb'       => 'commented',
      'created_at' => '2011-08-18T22:55:03-07:00',
      'points'     => 30,
      'player_id'  => '28d96559be245bf658e9d90a3bca4d29',
      'user_id'    => 'f1c385726538d79e43795d6a4006e7fd',
      'rewards'    => [{'name' => 'first_comment'}, {'name' => 'first_share'}]
    }
  end

  describe 'create' do
    before(:each) do
      stub_request(:post, /.*\/activities\.json$/).to_return(
        status: 201,
        body: activity_json.to_json
      )
    end

    it 'creates the activity for the player at badgeville when player_id is given' do
      Badgeville::Activity.create({player_id: 'PLAYER_ID', verb: 'commented'})

      a_request(:post, /.*\/activities\.json$/).with(
        body: {player_id: 'PLAYER_ID', activity: {verb: 'commented'}},
        headers: {'Content-Type' => 'application/json'}
      ).should have_been_made
    end

    it 'creates the activity for the player at badgeville when site and email is given' do
      Badgeville::Activity.create({site: 'SITE', email: 'EMAIL', verb: 'commented'})

      a_request(:post, /.*\/activities\.json$/).with(
        body: {site: 'SITE', email: 'EMAIL', activity: {verb: 'commented'}},
        headers: {'Content-Type' => 'application/json'}
      ).should have_been_made
    end

    # Badgeville actually prefers to get the player_id instead of the user & email
    # combination. This should also be faster.
    it 'prefers player_id if player_id, site and email is given' do
      Badgeville::Activity.create({player_id: 'PLAYER_ID', site: 'SITE', email: 'EMAIL', verb: 'commented'})

      a_request(:post, /.*\/activities\.json$/).with(
        body: {player_id: 'PLAYER_ID', activity: {verb: 'commented'}},
        headers: {'Content-Type' => 'application/json'}
      ).should have_been_made
    end

    it 'allows to add arbitrary meta data to the activity' do
      Badgeville::Activity.create({player_id: 'PLAYER_ID', verb: 'commented', content: 'First post!'})

      a_request(:post, /.*\/activities\.json$/).with(
        body: {player_id: 'PLAYER_ID', activity: {verb: 'commented', content: 'First post!'}},
        headers: {'Content-Type' => 'application/json'}
      ).should have_been_made
    end

    it 'raises an ArgumentError when player_id or site and email is not given' do
      expect {
        Badgeville::Activity.create(site: 'example.org')
      }.to raise_error(ArgumentError, 'You have to provide a player_id or a site and email')

      expect {
        Badgeville::Activity.create(email: 'user@example.org')
      }.to raise_error(ArgumentError, 'You have to provide a player_id or a site and email')
    end

    it 'returns the activity object' do
      activity = Badgeville::Activity.create({player_id: 'PLAYER_ID', verb: 'commented'})

      activity.should be_a(Badgeville::Activity)
      activity.verb.should == 'commented'
    end

    it 'handles the errors' do
      pending('TODO: Handle all errors. First find out how Badgeville responds')
    end
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
