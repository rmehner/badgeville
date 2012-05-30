require 'spec_helper'

describe Badgeville::Client do
  before do
    @user = "user"
    @badgeville = Badgeville::Client.new @user, 'private_key' => "api_key",
      'site' => 'example.com'
  end

  describe "#log_activity" do
    let(:result) do
      {
        'verb'       => 'commented',
        'created_at' => '2011-08-30T12:27:47-07:00',
        'rewards'    => []
      }
    end

    before(:each) do
      stub_http_request(
        :post,
        /#{Badgeville::Client::PROTOCOL}:\/\/#{Badgeville::Client::HOST}.*activities\.json/
      ).to_return(
        body: result.to_json
      )
    end

    it 'creates the activity at badgeville' do
      @badgeville.log_activity 'commented'
      a_request(
        :post,
        /.*#{Badgeville::Client::HOST}.*/
      ).with(body: 'activity[verb]=commented&user=user&site=example.com').should have_been_made
    end

    it 'returns an activity' do
      @badgeville.log_activity('commented').should be_a(Badgeville::Activity)
    end

    it 'initializes the activity with the response' do
      Badgeville::Activity.should_receive(:new).with(result)

      @badgeville.log_activity 'commented'
    end
  end

  describe "#get_activities" do
    before do
      @url = /#{Badgeville::Client::PROTOCOL}:\/\/#{Badgeville::Client::HOST}.*activities.json.*user=#{@user}.*/
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
      site           = "example.com"
      base_url       = "#{Badgeville::Client::PROTOCOL}://#{Badgeville::Client::HOST}/api/berlin/api_key/activities.json"
      total_url      = base_url + "?include_totals=true&site=#{site}&user=#{@user}"
      @total_count   = 2
      total_response = {
        "data" => [],
        "paging" => {
          "total_entries" => @total_count
        }
      }

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
      @url = /#{Badgeville::Client::PROTOCOL}:\/\/#{Badgeville::Client::HOST}.*reward_definitions.json.*user=#{@user}.*/
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
    let(:reward) {stub(:reward, id: 5, earned_at: Time.now)}

    before do
      @url = /#{Badgeville::Client::PROTOCOL}:\/\/#{Badgeville::Client::HOST}.*rewards\/5.json/
      stub_http_request(:delete, @url).to_return(status: 200)
    end

    it "succeed for an earned reward" do
      @badgeville.delete(reward).should be_true
    end

    it "fails for an un-earned reward (reward definition)" do
      reward.stub(earned_at: nil)

      lambda {
        @badgeville.delete(reward)
      }.should raise_error(Badgeville::BadgevilleError)
    end

    it "fails for non reward object" do
      lambda {
        @badgeville.delete(nil)
      }.should raise_error(Badgeville::BadgevilleError)
    end

    it "handles response error codes" do
      stub_http_request(:delete, @url).to_return(status: 500)
      lambda {
        @badgeville.delete(reward)
      }.should raise_error(Badgeville::BadgevilleError)
    end
  end

  describe "#player_info" do
    before do
      @url = /#{Badgeville::Client::PROTOCOL}:\/\/#{Badgeville::Client::HOST}.*\/players\/info\.json.*email=#{@user}.*/
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

  describe "#create_player" do
    before do
      url = /#{Badgeville::Client::PROTOCOL}:\/\/#{Badgeville::Client::HOST}.*\/players\/info\.json.*email=#{@user}.*/
      stub_http_request(:get, url).to_return(:status => 404,
        :body => {"errors" => {"error" => "invalid player"}}.to_json)

      players_url = /#{Badgeville::Client::PROTOCOL}:\/\/#{Badgeville::Client::HOST}.*\/players\.json/
      body = "email=#{@user}&site=example.com&player[email]=#{@user}"
      result = {"_id" => "1","id" => "1", "site_id" => "site_id"}
      stub_http_request(:post, players_url).with(body: body).
        to_return(:body => result.to_json)

      @users_url = /#{Badgeville::Client::PROTOCOL}:\/\/#{Badgeville::Client::HOST}.*\/users\.json/
      @users_body = "user[email]=#{@user}"
    end

    context "with new user" do
      before do
        result = {"_id" => "1","email" => @user}
        stub_http_request(:post, @users_url).with(body: @users_body).
          to_return(:body => result.to_json)
        @response = @badgeville.create_player
      end

      it "returns the created player id" do
        @response.should == "1"
      end

      it "sets player id" do
        @badgeville.player_id.should == "1"
      end

    context "with existing user on new site" do
      before do
          result = {"errors" => {"email" => ["user email is already taken"]}}
          stub_http_request(:post, @users_url).with(body: @users_body).
            to_return(:status => 422, :body => result.to_json)
          @response = @badgeville.create_player
        end
      end

      it "returns the created player id" do
        @response.should == "1"
      end

      it "sets player id" do
        @badgeville.player_id.should == "1"
      end
    end

    context "when player already exists" do
      before do
        url = /#{Badgeville::Client::PROTOCOL}:\/\/#{Badgeville::Client::HOST}.*\/players\/info\.json.*email=#{@user}.*/
        stub_http_request(:get, url).
          to_return(:body => {"data" => {"id" => "1", "site_id" => "site"}}.to_json)
        @response = @badgeville.create_player
      end

      it "returns the created player id" do
        @response.should == "1"
      end

      it "sets player id" do
        @badgeville.player_id.should == "1"
      end
    end
  end
end
