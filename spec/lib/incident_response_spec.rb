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

  describe ".parse_timestamp" do
    before(:each) do
      allow(Config).to receive(:time_zone).and_return('US/Pacific')
    end

    let(:date_in_dst) do
      ActiveSupport::TimeZone[Config.time_zone].parse('2016-09-07 05:00:00 PDT')
    end

    let(:date_not_in_dst) do
      ActiveSupport::TimeZone[Config.time_zone].parse('2015-12-07 05:00:00 PDT')
    end

    let(:test_date) { date_in_dst }
    let(:threepm_pdt) { test_date.time_zone.local(test_date.year, test_date.month, test_date.day, 15, 0, 0) }
    let(:threepm_edt) { ActiveSupport::TimeZone["US/Eastern"].local(test_date.year, test_date.month, test_date.day, 15, 0, 0) }
    let(:threepm_est) { ActiveSupport::TimeZone["US/Eastern"].local(date_not_in_dst.year, date_not_in_dst.month, date_not_in_dst.day, 15, 0, 0) }

    it "handles relative times" do
      Timecop.freeze(test_date) do
        expect(IncidentResponse.parse_timestamp("5 minutes ago")).to eq(test_date - 5.minutes)
      end
    end


    it "handles times starting with 'at'" do
      Timecop.freeze(test_date) do
        expect(IncidentResponse.parse_timestamp("at 3pm")).to eq threepm_pdt
      end
    end

    it "handles times with time zones" do
      Timecop.freeze(test_date) do
        expect(IncidentResponse.parse_timestamp("3pm EDT")).to eq threepm_edt
        expect(IncidentResponse.parse_timestamp("3pm -0400")).to eq threepm_edt
      end
    end

    it "corrects 'EST' to 'EDT' during daylight time" do
      Timecop.freeze(date_in_dst) do
        expect(IncidentResponse.parse_timestamp("3pm EST")).to eq threepm_edt
      end
    end

    it "corrects 'EDT' to 'EST' during standard time" do
      Timecop.freeze(date_not_in_dst) do
        expect(IncidentResponse.parse_timestamp("3pm EDT")).to eq threepm_est
      end
    end
  end
end
