RSpec.describe Mediators::User::Sync do
  before do
    Config.override :chatops_users_url, "https://example.com/users"
    Config.override :chatops_users_api_key, "sekrit"
  end

  describe "#call" do
    let(:url) { "#{Config.chatops_users_url}?secret=#{Config.chatops_users_api_key}" }
    let(:user1) { build(:user) }
    let(:user2) { build(:user) }

    let(:modified_user1) { build(:user, name: "changed name", handle: user1.handle, email: user1.email) }

    it "loads users returned from the chatops users request" do
      stub_request(:get, url).to_return body: [user1.as_json, user2.as_json].to_json

      Mediators::User::Sync.run

      expect(User.find_by(email: user1.email)).to be_same_as user1
      expect(User.find_by(email: user2.email)).to be_same_as user2
    end

    it "updates a user to match chatops user's info based on email" do
      stub_request(:get, url).to_return body: [modified_user1.as_json].to_json
      user1.save

      Mediators::User::Sync.run

      expect(User.find_by(email: user1.email)).to be_same_as modified_user1
    end


  end
end
