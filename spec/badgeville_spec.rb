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
        @activity.created_at.iso8601.should == Time.parse(@result["created_at"]).iso8601
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

  describe "#count_activities" do
    before do
      site = "example.com"
      base_url = "http://#{Badgeville::HOST}/api/berlin/api_key/activities.json"
      total_url = base_url + "?include_totals=true&site=#{site}&user=#{@user}"
      @total_count = 2
      total_response = {"data" => [],
        "paging" => {"total_entries" => @total_count}}
      stub_http_request(:get, total_url).to_return(:body => total_response.to_json)
      @verb_count = 1
      verb_url = base_url + "?include_totals=true&site=#{site}&user=#{@user}&verb=verb"
      verb_response = {"data" => [],
        "paging" => {"total_entries" => @verb_count}}
      stub_http_request(:get, verb_url).
        to_return(:body => verb_response.to_json)
    end

    it "returns total count when a verb is not specified" do
      @badgeville.count_activities.should == @total_count
    end

    it "returns num of activities per verb when specified" do
      @badgeville.count_activities(:verb => "verb").should == @verb_count
    end
  end

  describe "#reward_definitions" do
    before do
      @url = /http:\/\/#{Badgeville::HOST}.*reward_definitions.json.*user=#{@user}.*/
      rewards_on_first_page = {
        "data" => [{"name" => "Big Bang"}],
        "paging" => {"current_page" => 1,"total_pages" => 2}
      }
      rewards_on_second_page = {
        "data" => [{"name" => "Small Bang"}],
        "paging" => {"current_page" => 2,"total_pages" => 2}
      }

      stub_http_request(:get, @url).to_return(
        {:body => rewards_on_first_page.to_json},
        {:body => rewards_on_second_page.to_json}
      )

      @rewards = @badgeville.reward_definitions
    end

    it "should return an array of all rewards" do
      @rewards.class.should be(Array)
      @rewards.count.should == 2

      @rewards.first.class.should be(Badgeville::Reward)
      @rewards.first.name.should == "Big Bang"

      @rewards[1].class.should be(Badgeville::Reward)
      @rewards[1].name.should == "Small Bang"
    end
  end

  describe "#delete" do
    before do
      @mock_reward = Badgeville::Reward.new
      @mock_reward.id = 5
      @mock_reward.earned_at = Time.now
      @url = /http:\/\/#{Badgeville::HOST}.*rewards\/5.json/
      stub_http_request(:delete, @url).to_return(:status => 200)
    end

    it "succeed for an earned reward" do
      @badgeville.delete(@mock_reward).should be_true
    end

    it "fails for an un-earned reward (reward definition)" do
      @mock_reward.earned_at = nil
      lambda {
        @badgeville.delete(@mock_reward)
      }.should raise_error(Badgeville::BadgevilleError)
    end

    it "fails for non reward object" do
      lambda {
        @badgeville.delete(nil)
      }.should raise_error(Badgeville::BadgevilleError)
    end

    it "handles response error codes" do
      stub_http_request(:delete, @url).to_return(:status => 500)
      lambda {
        @badgeville.delete(@mock_reward)
      }.should raise_error(Badgeville::BadgevilleError)
    end
  end

  describe "#set_player" do
    before do
      @url = /http:\/\/#{Badgeville::HOST}.*\/players\/info\.json.*email=#{@user}.*/
      stub_http_request(:get, @url).to_return(:body => {"data" => {"id" => "1", "site_id" => "site"}}.to_json)
    end

    it {@badgeville.player_id.should == "1"}
    it {@badgeville.site_id.should == "site"}
  end

  describe "verify default timeout is 3" do
    it {@badgeville.timeout.should == 3}
  end

  describe "verify timeout parameter is set" do
    new_badgeville = Badgeville::Client.new @user, 'private_key' => "api_key",
      'site' => 'example.com', 'timeout' => 10
    it {new_badgeville.timeout.should == 10}
  end

end
