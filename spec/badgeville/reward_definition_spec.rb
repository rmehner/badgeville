require 'spec_helper'

describe Badgeville::RewardDefinition do
  before(:each) do
    Badgeville.configure(private_key: 'PRIVATE_API_KEY')
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

  describe '.find_by_site' do
    before(:each) do
      stub_request(:get, /.*\/reward_definitions\.json/).to_return(
        status: 200,
        body: {data: [reward_json]}.to_json
      )
    end

    it 'finds every reward definition for the site' do
      Badgeville::RewardDefinition.find_by_site('SITE')

      stub_request(:get, /.*\/reward_definitions\.json/).with(
        query: {'site' => 'SITE', 'page' => '1', 'per_page' => '50', 'include_totals' => 'true'}
      ).should have_been_made
    end

    it 'returns an empty array if no reward definitions could be found' do
      stub_request(:get, /.*\/reward_definitions\.json/).to_return(
        status: 200,
        body: {data: []}.to_json
      )

      reward_definitions = Badgeville::RewardDefinition.find_by_site('SITE')

      reward_definitions.should be_empty
    end

    it 'returns an array of reward objects' do
      rewards = Badgeville::RewardDefinition.find_by_site('SITE')

      rewards.first.should be_a(Badgeville::Reward)
      rewards.first.name.should == 'A Way with Words'
    end

    it 'gets ALL the rewards with pagination' do
      stub_request(:get, /.*\/reward_definitions\.json/).to_return(
        {body: {data: [reward_json], paging: {current_page: 1, total_pages: 3}}.to_json},
        {body: {data: [reward_json.merge(name: 'Typinghero')], paging: {current_page: 2, total_pages: 3}}.to_json},
        {body: {data: [reward_json.merge(name: 'Eduard Khil')], paging: {current_page: 3, total_pages: 3}}.to_json},
      )

      rewards = Badgeville::RewardDefinition.find_by_site('SITE')

      rewards.should have(3).items
      rewards[0].name.should == 'A Way with Words'
      rewards[1].name.should == 'Typinghero'
      rewards[2].name.should == 'Eduard Khil'
    end
  end

  describe '.update' do
    it 'updates the player' do
      stub_request(:put, /.*\/reward_definitions\/DEFINITION_ID\.json/).to_return(
        status: 200
      )

      Badgeville::RewardDefinition.update('DEFINITION_ID', {adjustments: {points: 100}})

      a_request(:put, /.*\/reward_definitions\/DEFINITION_ID\.json/).with(
        body: {reward_definition: {adjustments: {points: 100}}},
        headers: {'Content-Type' => 'application/json'}
      ).should have_been_made
    end

    it 'returns the errors why the update was not successful' do
      pending('TODO: Handle all errors. First find out how Badgeville responds')
    end
  end
end
