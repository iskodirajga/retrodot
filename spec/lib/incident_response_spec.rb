RSpec.describe IncidentResponse do
  describe '.get_mentioned_users' do
    before(:each) do
      @old_max_words_in_name = Config.max_words_in_name
    end

    after(:each) do
      Config.override :max_words_in_name, @old_max_words_in_name
    end

    let!(:user1) { FactoryGirl.create(:user) }
    let!(:user2) { FactoryGirl.create(:user) }

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

    let!(:john) { FactoryGirl.create(:user, name: "John Jones", handle: "john") }
    let!(:jsmith) { FactoryGirl.create(:user, name: "John Smith", handle: "jsmith") }
    let!(:jsj) { FactoryGirl.create(:user, name: "John Smith-Jones", handle: "jsj") }

    it 'returns users mentioned by full name' do
      # note that John Jones is NOT returned here
      expect(IncidentResponse.get_mentioned_users("lorem ipsum John Smith dolor sit")).to eq [jsmith]
    end

    it 'matches full names case-insensitively' do
      expect(IncidentResponse.get_mentioned_users("lorem ipsum joHN SmItH dolor sit")).to eq [jsmith]
    end

    it 'matches names up to Config.max_words_in_name in length' do
      Config.override :max_words_in_name, 2
      expect(IncidentResponse.get_mentioned_users("lorem ipsum John Smith-Jones dolor sit")).to eq [jsmith]

      Config.override :max_words_in_name, 3
      # note that John Smith is NOT returned here
      expect(IncidentResponse.get_mentioned_users("lorem ipsum John Smith-Jones dolor sit")).to eq [jsj]
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
  end
end
