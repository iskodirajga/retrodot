RSpec.describe IncidentResponse do
  describe '.get_mentioned_users' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    it 'returns a user mentioned by handle without @' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum #{user1.handle} dolor sit")).to eq [user1]
      expect(IncidentResponse.get_mentioned_users("lorem ipsum #{user1.handle}")).to eq [user1]
      expect(IncidentResponse.get_mentioned_users("#{user1.handle} dolor sit")).to eq [user1]
    end

    it 'returns a user mentioned by handle with @' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum @#{user1.handle} dolor sit")).to eq [user1]
    end

    it 'matches handles with contractions and possessive forms' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum @#{user1.handle}'s dolor sit")).to eq [user1]
      expect(IncidentResponse.get_mentioned_users("lorem ipsum #{user1.handle}'s dolor sit")).to eq [user1]
    end

    it 'de-duplicates users mentioned multiple times by handle' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum @#{user1.handle} dolor #{user1.handle} sit")).to eq [user1]
    end

    it 'returns multiple users mentioned by handles' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum @#{user1.handle} dolor #{user2.handle} sit")).to match_array([user1, user2])
    end

    let!(:john) { create(:user, name: "John Jones", handle: "john") }
    let!(:jsmith) { create(:user, name: "John Smith", handle: "jsmith") }
    let!(:jsj) { create(:user, name: "John Smith-Jones", handle: "jsj") }

    it 'returns users mentioned by full name' do
      # note that John Jones (whose handle is "john") is NOT returned here
      expect(IncidentResponse.get_mentioned_users("lorem ipsum John Smith dolor sit")).to eq [jsmith]
    end

    it 'matches full names case-insensitively' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum joHN SmItH dolor sit")).to eq [jsmith]
    end

    it 'matches full names without regard for whitespace' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum john  smith dolor sit")).to eq [jsmith]
    end

    it 'matches names with contractions and possessive forms' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum John Smith's here!")).to eq [jsmith]
    end

    it 'returns people mentioned by name and handle and de-duplicates' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum #{user1.name} dolor #{user2.name} sit #{user1.handle}")).to match_array([user1, user2])
    end

    it 'returns no users if none are mentioned' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum dolor sit amet")).to eq []
    end

    it 'does not let one name overshadow another' do
      # If "John Smith-Jones" is in the message, we need to make sure that he
      # is returned, not John Smith.
      expect(IncidentResponse.get_mentioned_users("lorem ipsum John Smith-Jones dolor sit")).to eq [jsj]
    end

    it 'does not match handles that are not whole words' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum qjsmith dolor sit")).to eq []
      expect(IncidentResponse.get_mentioned_users("lorem ipsum jsmithq dolor sit")).to eq []
    end
  end

  describe ".prevent_highlights" do
    let(:turtle) { "\u{1f422}" }
    let(:separator) { "\u{2063}" }
    let!(:user1) { create(:user, handle: "foo") }

    it "should leave messages unchanged if they don't contain handles" do
      s = "lorem ipsum dolor sit amet"
      expect(IncidentResponse.prevent_highlights(s)).to eq s
    end

    it "should intersperse invisible separator into handles" do
      before = "lorem ipsum foo dolor sit amet"
      after = "lorem ipsum f#{separator}o#{separator}o dolor sit amet"
      expect(IncidentResponse.prevent_highlights(before)).to eq after
    end

    it "should work even for contractions" do
      before = "lorem ipsum foo're dolor sit amet"
      after = "lorem ipsum f#{separator}o#{separator}o're dolor sit amet"
      expect(IncidentResponse.prevent_highlights(before)).to eq after
    end
  end
end