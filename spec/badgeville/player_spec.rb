require 'spec_helper'

describe Badgeville::Player do
  before(:each) do
    Badgeville.configure(private_key: 'private_key')
  end

  let(:player_json) do
    {
      'data' => {
        '_id'                 => '2769b93e81ecd9cf242afb1f884783c5',
        'id'                  => 'a1bb043d9c6943ef4ecfc8d2ad454dcb', # officially _id is the real id
        'name'                => nil,
        'first_name'          => 'Robin',
        'last_name'           => 'Mehner',
        'display_name'        => 'rmehner',
        'nick_name'           => 'rmehner',
        'email'               => 'robin@coding-robin.de',
        'user_email'          => 'robin@coding-robin.de',
        'created_at'          => '2012-05-21T08:25:34-07:00',
        'user_id'             => '04fb06eef3fcebc766d49ca38ccede3f',
        'site_id'             => 'f8b9bdc26ba18b2056177ada95c0f0cb',
        'site_url'            => 'example.org',
        'admin'               => false,
        'points_day'          => 26.0,
        'points_week'         => 127.0,
        'points_month'        => 249.0,
        'points_all'          => 1337.0,
        'facebook_id'         => 'facebook_id',
        'facebook_link'       => 'http://facebook_link',
        'twitter_id'          => 'twitter_id',
        'twitter_username'    => 'rmehner',
        'twitter_link'        => 'http://twitter.com/rmehner',
        'email_notifications' => true,
        'custom_picture_url'  => 'http://myavatarexample.org/picture.png',
        'picture_url'         => 'https://sandbox.v2.badgeville.com/images/misc/missing/bar/user_nopicture.png',
        'preferences'         => {
          'email_notifications' => true,
          'hide_notifications'  => false,
          'publish_activity'    => true
        },
        'teams' => [
          '66bcc4d3fd9e16ce9c8b939ea09d6854'
        ],
        'units' => {
          'points_day'   => 26.0,
          'points_week'  => 127.0,
          'points_month' => 249.0,
          'points_all'   => 1337.0,
          'unit_xp'      => 1
        }
      }
    }
  end

  describe '.find_by_email_and_site' do
    before(:each) do
      stub_request(:get, /.*players\/info\.json/).to_return(
        status: 200,
        body: player_json.to_json
      )
    end

    it 'finds the player info from Badgeville' do
      Badgeville::Player.find_by_email_and_site(
        'robin@coding-robin.de',
        'example.org'
      )

      a_request(
        :get,
        /#{Badgeville::Client::PROTOCOL}:\/\/#{Badgeville::Client::HOST}.*players/
      ).should have_been_made
    end

    it 'initializes the player with the returned JSON' do
      player = Badgeville::Player.find_by_email_and_site(
        'robin@coding-robin.de',
        'example.org'
      )

      player.id.should == '2769b93e81ecd9cf242afb1f884783c5'
    end

    it 'returns nil if the player could not be found' do
      stub_request(:get, /.*players\/info\.json/).to_return(
        status: 404
      )

      Badgeville::Player.find_by_email_and_site(
        'robin@coding-robin.de',
        'example.org'
      ).should be_nil
    end
  end

  describe '.create' do
    before(:each) do
      stub_request(:post, /.*\/players\.json$/).to_return(
        status: 201,
        body: player_json['data'].to_json
      )
    end

    it 'creates a player at badgeville with user_id and site_id' do
      # POST /players.json {player: {user_id: 'XX', site_id: 'ID', ...}}
      Badgeville::Player.create({
        user_id: 'USER_ID',
        site_id: 'SITE_ID',
        display_name: 'rmehner'
      })

      a_request(:post, /.*\/players\.json$/).with(
        body: hash_including({player: {user_id: 'USER_ID', site_id: 'SITE_ID', display_name: 'rmehner'}}),
        headers: {'Content-Type' => 'application/json'}
      ).should have_been_made
    end

    it 'creates a player at badgeville with email and site' do
      Badgeville::Player.create({
        email: 'robin@coding-robin.de',
        site: 'example.org',
        display_name: 'rmehner'
      })

      a_request(:post, /.*\/players\.json$/).with(
        body: {email: 'robin@coding-robin.de', site: 'example.org', player: {display_name: 'rmehner'}},
        headers: {'Content-Type' => 'application/json'}
      ).should have_been_made
    end

    it 'returns a player object on success' do
      player = Badgeville::Player.create({
        user_id: 'USER_ID',
        site_id: 'SITE_ID',
        display_name: 'rmehner'
      })

      player.should be_a(Badgeville::Player)
      player.display_name.should == 'rmehner'
    end

    it 'handles the error when site_id is given but user_id is not' do
      -> {
        Badgeville::Player.create({
          site_id: 'SITE_ID',
          display_name: 'rmehner'
        })
      }.should raise_error(ArgumentError, 'You have to provide either user_id and site_id or email and site')
    end

    it 'raises an ArgumentError if site is given but user is not' do
      -> {
        Badgeville::Player.create({
          site: 'example.org',
          display_name: 'rmehner'
        })
      }.should raise_error(ArgumentError, 'You have to provide either user_id and site_id or email and site')
    end

    it 'handles the error when the email is already taken' do
      pending('TODO: Handle all errors. First find out how Badgeville responds')
    end
  end

  describe '.update' do
    it 'updates the player' do
      stub_request(:put, /.*\/players\/USER_ID\.json/).to_return(
        status: 200
      )

      Badgeville::Player.update('USER_ID', {first_name: 'Robin'})

      a_request(:put, /.*\/players\/USER_ID\.json/).with(
        body: {player: {first_name: 'Robin'}},
        headers: {'Content-Type' => 'application/json'}
      ).should have_been_made
    end

    it 'returns the errors why the update was not successful' do
      pending('TODO: Handle all errors. First find out how Badgeville responds')
    end
  end

  describe 'initialize' do
    it 'sets the attributes for the player' do
      player = Badgeville::Player.new(player_json['data'])
      player.id.should                  == '2769b93e81ecd9cf242afb1f884783c5'
      player.email.should               == 'robin@coding-robin.de'
      player.facebook_link.should       == 'http://facebook_link'
      player.units['unit_xp'].should    == 1
      player.units['points_day'].should == 26.0
      player.teams.should               == ['66bcc4d3fd9e16ce9c8b939ea09d6854']
    end
  end

  describe 'created_at' do
    it 'returns created_at as Time' do
      player = Badgeville::Player.new(player_json['data'])
      player.created_at.iso8601.should == Time.parse(player_json['data']['created_at']).iso8601
    end
  end
end
