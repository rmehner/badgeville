require 'spec_helper'

describe Badgeville::Reward do
  before(:each) do
    Badgeville.configure(private_key: 'PRIVATE_KEY')
  end

  let(:reward_json) do
    {
      'name'             => 'A Way with Words',
      'active_start_at'  => nil,
      'image_file_name'  => '9fQ2IU6-0.ftbs4fsoogp3c8fr.png',
      'data'             => {
        'verb'      => 'commented',
        'threshold' => 2
      },
      'created_at' => '2011-08-18T22:55:03-07:00',
      'image_url'  => 'http://s3.amazon.com/original.png?1',
      'components' => [
        {
          'command'    => 'count',
          'comparator' => {
            '$gte' => 2
          },
          'config' => {
          },
          'where'=> {
            'verb'      => 'commented',
            'player_id' => '%player_id'
          }
        }
      ],
      'reward_template'  => {
        'message' => ''
      },
      '_id'              => '4e4dfab6c47eed727b005c38',
      'tags'             => nil,
      'id'               => '4e4dfab6c47eed727b005c38',
      'active_end_at'    => nil,
      'type'             => 'achievement',
      'hint'             => 'Reply to 25 Comments',
      'assignable'       => false,
      'allow_duplicates' => false,
      'site_id'          => '4e4d5bf5c47eed25a0000e8f',
      'active'           => true,
      'message'          => 'You won the internet!'
    }
  end

  describe 'find_by_player_id' do
    before(:each) do
      stub_request(:get, /.*\/rewards\.json/).to_return(
        status: 200,
        body: {data: [reward_json]}.to_json
      )
    end

    it 'finds every reward for the player by the player_id' do
      Badgeville::Reward.find_by_player_id('PLAYER_ID')

      a_request(:get, /.*\/rewards\.json/).with(
        query: {
          'player_id'      => 'PLAYER_ID',
          'page'           => '1',
          'per_page'       => '50',
          'include_totals' => 'true'
        }
      ).should have_been_made
    end

    it 'returns an empty array if no rewards could be found' do
      stub_request(:get, /.*\/rewards\.json/).to_return(
        status: 200,
        body: {data: []}.to_json
      )

      rewards = Badgeville::Reward.find_by_player_id('PLAYER_ID')

      rewards.should be_empty
    end

    it 'returns an array of reward objects' do
      rewards = Badgeville::Reward.find_by_player_id('PLAYER_ID')
      rewards.first.should be_a(Badgeville::Reward)
      rewards.first.name.should == 'A Way with Words'
    end

    it 'gets ALL the rewards with pagination' do
      stub_request(:get, /.*\/rewards\.json/).to_return(
        {body: {data: [reward_json], paging: {current_page: 1, total_pages: 3}}.to_json},
        {body: {data: [reward_json.merge(name: 'Typinghero')], paging: {current_page: 2, total_pages: 3}}.to_json},
        {body: {data: [reward_json.merge(name: 'Eduard Khil')], paging: {current_page: 3, total_pages: 3}}.to_json},
      )

      rewards = Badgeville::Reward.find_by_player_id('PLAYER_ID')

      rewards.should have(3).items
      rewards[0].name.should == 'A Way with Words'
      rewards[1].name.should == 'Typinghero'
      rewards[2].name.should == 'Eduard Khil'
    end

    it 'returns an empty array if Badgeville returns with 404' do
      stub_request(:get, /.*\/rewards\.json/).to_return(
        status: 404
      )

      rewards = Badgeville::Reward.find_by_player_id('PLAYER_ID')

      rewards.should be_empty
    end
  end

  describe 'find_by_email_and_site' do
    before(:each) do
      stub_request(:get, /.*\/rewards\.json/).to_return(
        status: 200,
        body: {data: [reward_json]}.to_json
      )
    end

    it 'finds every reward for the player by the email and site' do
      Badgeville::Reward.find_by_email_and_site('user@example.org', 'example.org')

      a_request(:get, /.*\/rewards\.json/).with(
        query: {
          'site'           => 'example.org',
          'email'          => 'user@example.org',
          'page'           => '1',
          'per_page'       => '50',
          'include_totals' => 'true'
        }
      ).should have_been_made
    end

    it 'returns an empty array if no rewards could be found' do
      stub_request(:get, /.*\/rewards\.json/).to_return(
        status: 200,
        body: {data: []}.to_json
      )

      rewards = Badgeville::Reward.find_by_email_and_site('user@example.org', 'example.org')

      rewards.should be_empty
    end

    it 'returns an array of reward objects' do
      rewards = Badgeville::Reward.find_by_email_and_site('user@example.org', 'example.org')
      rewards.first.should be_a(Badgeville::Reward)
      rewards.first.name.should == 'A Way with Words'
    end

    it 'gets ALL the rewards with pagination' do
      stub_request(:get, /.*\/rewards\.json/).to_return(
        {body: {data: [reward_json], paging: {current_page: 1, total_pages: 3}}.to_json},
        {body: {data: [reward_json.merge(name: 'Typinghero')], paging: {current_page: 2, total_pages: 3}}.to_json},
        {body: {data: [reward_json.merge(name: 'Eduard Khil')], paging: {current_page: 3, total_pages: 3}}.to_json},
      )

      rewards = Badgeville::Reward.find_by_email_and_site('user@example.org', 'example.org')

      rewards.should have(3).items
      rewards[0].name.should == 'A Way with Words'
      rewards[1].name.should == 'Typinghero'
      rewards[2].name.should == 'Eduard Khil'
    end

    it 'returns an empty array if Badgeville returns with 404' do
      stub_request(:get, /.*\/rewards\.json/).to_return(
        status: 404
      )

      rewards = Badgeville::Reward.find_by_email_and_site('user@example.org', 'example.org')

      rewards.should be_empty
    end
  end

  context "when json is a reward definition" do
    before do
      @reward = Badgeville::Reward.new(reward_json)
    end

    it "initialize based on json" do
      @reward.name.should == "A Way with Words"
      @reward.active.should be_true
      @reward.id.should == "4e4dfab6c47eed727b005c38"
      @reward.definition_id.should == '4e4dfab6c47eed727b005c38'
      @reward.message.should == 'You won the internet!'
      @reward.type.should == 'achievement'
      @reward.definition.should be_nil
    end

    describe "image_url" do
      it "returns the original url by default" do
        @reward.image_url.should == '//s3.amazon.com/original.png?1'
      end

      it "allows to request specific formats" do
        [:original, :large, :medium, :grayscale, :grayscale_small].each do |format|
          @reward.image_url(format).should == "//s3.amazon.com/#{format}.png?1"
        end
      end

      it "returns a protocol relative url for a http original image url" do
        @reward.image_url.should == '//s3.amazon.com/original.png?1'
      end

      it "returns a protocol relative url for a https original image url" do
        reward_json['image_url'] = 'https://s3.amazon.com/original.png?1'
        reward = Badgeville::Reward.new(reward_json)

        reward.image_url.should == '//s3.amazon.com/original.png?1'
      end

      it "returns nil if the image url is nil in the parsed json" do
        reward_json['image_url'] = nil
        reward = Badgeville::Reward.new(reward_json)

        reward.image_url.should be_nil
      end
    end

    describe "tags" do
      it "returns an empty array if no tag key is in the parsed json" do
        @reward = Badgeville::Reward.new({})

        @reward.tags.should == []
      end

      it "returns an empty array if no tags are defined" do
        @reward = Badgeville::Reward.new('tags' => nil)

        @reward.tags.should == []
      end

      it "returns the defined tag" do
        @reward = Badgeville::Reward.new('tags' => ['tag'])

        @reward.tags.should == ["tag"]
      end

      it "returns all defined tags" do
        @reward = Badgeville::Reward.new('tags' =>['tag1', 'tag2'])

        @reward.tags.should == ['tag1', 'tag2']
      end
    end
  end

  context "when json is a reward earned by user" do
    before do
      @user_reward_json = {
        'user_id'    => '1',
        'id'         => 'new_id',
        'created_at' => '2011-08-18T22:55:03-07:00',
        'definition' => reward_json
      }
      @reward = Badgeville::Reward.new(@user_reward_json)
    end

    it "initialize based on json" do
      @reward.name.should == "A Way with Words"
      @reward.image_url.should =~ /original.png/
      @reward.active.should be_true
      @reward.earned_at.iso8601.should == Time.parse(@user_reward_json["created_at"]).iso8601
      @reward.id.should == "new_id"
      @reward.definition_id.should == '4e4dfab6c47eed727b005c38'
      @reward.message.should == 'You won the internet!'
      @reward.type.should == 'achievement'
      @reward.definition.should == reward_json
    end
  end

  context "when reward is an achievement (has data with verb and threshold)" do
    before do
      @reward = Badgeville::Reward.new(reward_json)
    end

    it "has verb and threshold accessors" do
      @reward.verb.should == "commented"
      @reward.threshold.should == 2
    end
  end

  context "when reward is a level (has data with position and start_points)" do
    before do
      reward_json['type']                 = 'level'
      reward_json['data']['position']     = 3
      reward_json['data']['start_points'] = 300

      @reward = Badgeville::Reward.new(reward_json)
    end

    it 'has position and start_points accessors' do
      @reward.type.should == 'level'
      @reward.position.should == 3
      @reward.start_points.should == 300
    end
  end
end
