require 'spec_helper'

describe Badgeville::Group do
  before(:each) do
    Badgeville.configure(private_key: 'PRIVATE_API_KEY')
  end

  let(:reward_definition_beginner) do
    {
      "type"             => "achievement",
      "name"             => "beginner",
      "created_at"       => "2011-10-26T05:51:12-07:00",
      "assignable"       => false,
      "allow_duplicates" => false,
      "components"       => [
        {
          "comparator" => {
            "$gte" => 1
          },
          "command" => "count",
          "where" => {
            "verb"=>"join",
            "player_id"=>"%player_id"
          },
          "config"=>{
          }
        }
      ],
      "reward_template" => {
        "message" => "beginner_message"
      },
      "tags"            => nil,
      "site_id"         => "SITE_ID",
      "image_url"       => "http://s3.amazonaws.com/original.png?1",
      "image_file_name" => "beginner.png",
      "data"            => {
        "verb"      => "join",
        "threshold" => 1
      },
      "_id"                 => "reward_id_1",
      "id"                  => "reward_id_1",
      "active"              => true,
      "hint"                => "beginner_hint",
      "message"             => "beginner_message",
      "adjustment"          => {},
      "active_start_at"     => nil,
      "active_end_at"       => nil,
      "performed_by"        => nil,
      "reward_team_members" => false
    }
  end

  let(:reward_definition_collector) do
    {
      "type"             => "achievement",
      "name"             => "collector",
      "created_at"       => "2011-10-26T05:53:40-07:00",
      "assignable"       => false,
      "allow_duplicates" => false,
      "components"       => [
        {
          "comparator" => {
            "$gte" => 1
          },
          "command" => "count",
          "where"   => {
            "verb"      =>"redeem",
            "player_id" =>"%player_id"
          },
          "config" => {
          }
        }
      ],
      "reward_template" => {
        "message" => "collector_message"
      },
      "tags"            => nil,
      "site_id"         => "SITE_ID",
      "image_url"       => "http://s3.amazonaws.com/original.png?2",
      "image_file_name" => "collector.png",
      "data" => {
        "verb"      => "redeem",
        "threshold" => 1
      },
      "_id"                 => "reward_id_2",
      "id"                  => "reward_id_2",
      "active"              => true,
      "hint"                => "collector_hint",
      "message"             => "collector_message",
      "adjustment"          => {},
      "active_start_at"     => nil,
      "active_end_at"       => nil,
      "performed_by"        => nil,
      "reward_team_members" => false
    }
  end

  let(:group_json) do
    {
      "id"                 => "group_id",
      "name"               => "My Mission",
      "type"               => "collection",
      "image_url"          => "http://s3.amazonaws.com/original.gif?3",
      "tip"                => "this is a hint",
      "message"            => "Congratulations!",
      "privileges"         => nil,
      "note"               => "",
      "display_priority"   => 0,
      "reward_definitions" => [
        reward_definition_beginner,
        reward_definition_collector
      ],
      "reward_image_url" => "http://s3.amazonaws.com/original.gif?3",
      "track_member"     => false,
      "adjustment"       => {},
      "units_possible"   => {
        "points" => 55
      }
    }
  end

  describe '.find_by_site' do
    before(:each) do
      stub_request(:get, /.*\/groups\.json/).to_return(
        status: 200,
        body: {data: [group_json]}.to_json
      )
    end

    it 'allows to list all groups for one site' do
      Badgeville::Group.find_by_site('SITE')

      stub_request(:get, /.*\/groups\.json/).with(
        query: {'site' => 'SITE', 'page' => '1', 'per_page' => '50', 'include_totals' => 'true'}
      ).should have_been_made
    end

    it 'returns an array of Group objects' do
      groups = Badgeville::Group.find_by_site('SITE')

      groups.should have(1).item
      groups.first.should be_a(Badgeville::Group)
    end

    it 'returns an empty array if no groups were found' do
      stub_request(:get, /.*\/groups\.json/).to_return(
        status: 200,
        body: {data: []}.to_json
      )

      groups = Badgeville::Group.find_by_site('SITE')

      groups.should be_empty
    end
  end

  describe 'initialize' do
    context 'when initialized with json' do
      it 'sets the right attribute readers' do
        group = Badgeville::Group.new(group_json)

        group.name.should == 'My Mission'
        group.id.should == 'group_id'
        group.type.should == 'collection'
        group.image_url.should == "//s3.amazonaws.com/original.gif?3"
        group.tip.should == "this is a hint"
        group.hint.should == "this is a hint"
        group.message.should == "Congratulations!"
        group.privileges.should == nil
        group.note.should == ""
        group.display_priority.should == 0
        group.track_member.should == false
        group.adjustment.should be_a(Hash)
        group.units_possible['points'].should == 55
      end
    end
  end

  describe '#rewards' do
    it 'returns an array of Reward objects contained in the group' do
      group = Badgeville::Group.new(group_json)

      group.rewards.should have(2).items

      group.rewards.first.should be_a(Badgeville::Reward)
      group.rewards.first.name.should == 'beginner'
      group.rewards.first.type.should == 'achievement'
    end

    it 'returns an empty if the group has no reward definitions' do
      group = Badgeville::Group.new(group_json.merge('reward_definitions' => []))

      group.rewards.should have(0).items
    end
  end

  describe '#image_url' do
    before(:each) do
      @group = Badgeville::Group.new(group_json)
    end

    it 'returns the original url by default' do
      @group.image_url.should == '//s3.amazonaws.com/original.gif?3'
    end

    it 'allows to request specific formats' do
      [:original, :large, :medium, :grayscale, :grayscale_small].each do |format|
        @group.image_url(format).should == "//s3.amazonaws.com/#{format}.gif?3"
      end
    end

    it 'returns a protocol relative url for a http original image url' do
      @group.image_url.should == '//s3.amazonaws.com/original.gif?3'
    end

    it 'returns a protocol relative url for a https original image url' do
      group_json['image_url'] = 'https://s3.amazonaws.com/original.gif?3'
      group = Badgeville::Group.new(group_json)

      group.image_url.should == '//s3.amazonaws.com/original.gif?3'
    end

    it 'returns nil if the image url is nil in the parsed json' do
      group_json['image_url'] = nil
      group = Badgeville::Group.new(group_json)

      group.image_url.should be_nil
    end
  end
end
