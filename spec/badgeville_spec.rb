require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Badgeville do
  before do
    @user = "user"
    @badgeville = Badgeville::Client.new @user, 'private_key' => "api_key",
      'site' => 'example.com'
  end

  describe "#log_activity" do
    before do
      @action_name = "commented"
      @url = "http://" + Badgeville::HOST + ".*activities.json"
      @result = {"verb" => @action_name,
        "created_at" => "2011-08-30T12:27:47-07:00",
        "points" => 0,
        "player_id" => "4e5d3992c47eed202d00148c",
        "user_id" => "4e5d3992c47eed202d00148b",
        "rewards" =>[]
      }
      @body = "activity[verb]=#{@action_name}"
      @user_data = "&user=#{@user}&site=example.com"
    end

    context "when no meta data" do
      before do
        @body += @user_data
        stub_http_request(:post, Regexp.new(@url)).with(:body => @body).
          to_return(:body => @result.to_json)
        @activity =  @badgeville.log_activity @action_name
      end

      it "returns an activity object" do
        @activity.is_a? Badgeville::Activity
      end

      it "parses response from activity record api call" do
        @activity.verb.should == "commented"
        @activity.created_at.iso8601.should == @result["created_at"]
        @activity.points.should == 0
        @activity.rewards.should be_empty
        @activity.meta.should be_empty
      end
    end

    context "with meta data" do
      before do
        @team = "myteam"
        @result["team"] = @team
        @body += "&activity[team]=#{@team}" + @user_data

        stub_http_request(:post, Regexp.new(@url)).with(:body => @body).
          to_return(:body => @result.to_json)
        @activity =  @badgeville.log_activity @action_name, :team => @team
      end

      it "parses the meta data as well" do
        @activity.meta[:team] = @team
      end
    end
  end

  describe "#get_activities" do
    before do
      @url = /http:\/\/#{Badgeville::HOST}.*activities.json.*user=#{@user}.*/
      mock_activities = { 
        "data" => [
                   {
                     "verb" => "join_team",
                     "created_at" => "2011-09-01T14:12:13-07:00",
                     "rewards" => []
                   }
                  ]
      }
      stub_http_request(:get, @url).to_return(:body => mock_activities.to_json)
      @activities = @badgeville.get_activities
    end

    it "should return an array of activities" do
      @activities.class.should be(Array)
      @activities.first.class.should be(Badgeville::Activity)
    end
  end

  describe "#reward_definitions" do
    before do
      @url = /http:\/\/#{Badgeville::HOST}.*reward_definitions.json.*user=#{@user}.*/
      mock_rewards = {"data" => [{"name" => "Big Bang"}]}
      stub_http_request(:get, @url).to_return(:body => mock_rewards.to_json)
      @rewards = @badgeville.reward_definitions
    end

    it "should return an array of rewards" do
      @rewards.class.should be(Array)
      @rewards.first.class.should be(Badgeville::Reward)
    end
  end
end
