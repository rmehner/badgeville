require 'spec_helper'

describe Badgeville::Activity do
  before(:each) do
    Badgeville.configure(private_key: 'private_key')
  end

  let(:activity_json) do
    {
      '_id'            => 'ACTIVITY_ID',
      'contents'       => [],
      'created_at'     => '2011-08-18T22:55:03-07:00',
      'deleted_at'     => nil,
      'internal'       => false,
      'points'         => 30,
      'player_id'      => 'PLAYER_ID',
      'player_type'    => 'Player',
      'src_player'     => nil,
      'unit_rp'        => 40, # custom defined unit,
      'unit_xp'        => 50, # another custom defined unit
      'shard_id'       => 'SHARD_ID',
      'site_id'        => 'SITE_ID',
      'user_id'        => 'USER_ID',
      'rewards'        => [{'name' => 'first_comment'}, {'name' => 'first_share'}],
      'definition_ids' => ['DEFINITION_ID'],
      'verb'           => 'commented'
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

      activity.contents.should       == [] # no idea what this is
      activity.definition_ids.should == ['DEFINITION_ID']
      activity.points.should         == 30
      activity.player_type.should    == 'Player'
      activity.src_player.should     == nil # no idea what this is
      activity.shard_id.should       == 'SHARD_ID'
      activity.site_id.should        == 'SITE_ID'
      activity.player_id.should      == 'PLAYER_ID'
      activity.user_id.should        == 'USER_ID'
      activity.verb.should           == 'commented'
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

      activity.created_at.iso8601.should == Time.parse(activity_json['created_at']).iso8601
    end
  end

  describe 'deleted_at' do
    it 'returns the parsed date time of deleted at' do
      json     = activity_json.merge('deleted_at' => '2012-06-06T22:55:03-07:00')
      activity = Badgeville::Activity.new(json)

      activity.deleted_at.iso8601.should == Time.parse(json['deleted_at']).iso8601
    end

    it 'returns nil if the activity was not deleted' do
      activity = Badgeville::Activity.new(activity_json)

      activity.deleted_at.should be_nil
    end
  end

  describe 'internal?' do
    it 'returns false if the activity was not an internal one' do
      activity = Badgeville::Activity.new(activity_json)

      activity.internal?.should be_false
    end

    it 'returns true if the activity was an internal one (like bv_adjust_units)' do
      activity = Badgeville::Activity.new(activity_json.merge('internal' => true))

      activity.internal?.should be_true
    end
  end

  describe 'id' do
    it 'returns the id of the activity' do
      activity = Badgeville::Activity.new(activity_json)

      activity.id.should == 'ACTIVITY_ID'
    end
  end

  describe 'meta' do
    it 'returns unknown attributes as meta data' do
      activity = Badgeville::Activity.new(activity_json.merge({'team' => 'myteam'}))

      activity.meta[:team].should == 'myteam'
    end

    it 'does not return known attributes as meta data' do
      activity = Badgeville::Activity.new(activity_json)
      activity.meta.keys.should have(0).items
    end
  end

  describe 'points and units' do
    let(:activity) { Badgeville::Activity.new(activity_json) }

    it 'returns the points of the activity' do
      activity.points.should == 30
    end

    it 'returns custom point units' do
      activity.unit_rp.should == 40
      activity.unit_xp.should == 50
    end

    it 'responds to the custom unit methods' do
      activity.should respond_to(:unit_xp)
      activity.should respond_to(:unit_rp)
    end

    it 'does not respond to undefined custom units' do
      activity.should_not respond_to(:unit_custom)
    end

    # common gotcha, here as a small safety net
    it 'still raises a MethodMissing error for undefined methods' do
      expect {
        activity.undefined_method
      }.should raise_error(NoMethodError)
    end
  end
end
