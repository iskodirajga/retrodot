RSpec.describe ChatOps do
  let!(:commands) { ChatOps.commands }
  before { ChatOps.class_variable_set :@@commands, [] }
  after { ChatOps.class_variable_set :@@commands, commands }

  let(:cmd_1_class) { Class.new(ChatOps::Command) }
  let(:cmd_2_class) { Class.new(ChatOps::Command) }

  describe '.register' do
    it 'adds class to commands class variable' do
      Foo = Class.new

      ChatOps.register Foo

      expect(ChatOps.commands).to include Foo
    end
  end

  describe '.commands' do
    it 'returns an array object' do
      expect(ChatOps.commands).to be_an Array
    end

    it 'registers when some class inherits from ChatOps::Command' do
      expect(ChatOps.commands).to include cmd_1_class, cmd_2_class
    end
  end

  describe '.matcher' do
    it 'builds a regex from defined commands' do
      cmd_1_class.class_eval { match /test_regex1_[0-9]+/ }
      cmd_2_class.class_eval { match /test_regex2_[a-z]+/ }

      expect(ChatOps.matcher).to match 'test_regex1_0123'
      expect(ChatOps.matcher).to match 'test_regex2_abcdef'
    end
  end

  describe '.help' do
    let(:help1) { "command 1 help text" }
    let(:help2) { "command 2 help text" }

    it "joins all commands' help messages with newlines" do
      cmd_1_class.class_eval "help_message '#{help1}'"
      cmd_2_class.class_eval "help_message '#{help2}'"

      expect(ChatOps.help).to include help1, help2
    end

    it "skips classes that don't specify a help message" do
      cmd_1_class.class_eval "help_message '#{help1}'"

      expect(ChatOps.help).to eq help1
    end
  end

  describe '.process' do
    let!(:cmd_1_instance) { cmd_1_class.new }
    let!(:cmd_2_instance) { cmd_2_class.new }

    before do
      cmd_1_class.class_eval { match /test_regex1_[0-9]+/ }
      cmd_2_class.class_eval { match /test_regex2_[a-z]+/ }
      allow(cmd_1_class).to receive(:new) { cmd_1_instance }
      allow(cmd_2_class).to receive(:new) { cmd_2_instance }
    end

    it 'calls process on an instance of each defined command' do
      expect(cmd_1_instance).to receive(:process)
      expect(cmd_2_instance).to receive(:process)

      ChatOps.process('user', 'message')
    end

    it 'calls run only on the command that matched' do
      cmd_2_class.class_eval { def run(user, result); 'Command2.run'; end }

      expect(cmd_1_instance).not_to receive(:run)

      result = ChatOps.process('user', 'test_regex2_abcdef')

      expect(result).to eq 'Command2.run'
    end
  end

  describe '.get_mentioned_users' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    it 'returns a user mentioned by handle without @' do
      expect(ChatOps.get_mentioned_users("lorem ipsum #{user1.handle} dolor sit")).to eq [user1]
      expect(ChatOps.get_mentioned_users("lorem ipsum #{user1.handle}")).to eq [user1]
      expect(ChatOps.get_mentioned_users("#{user1.handle} dolor sit")).to eq [user1]
    end

    it 'returns a user mentioned by handle with @' do
      expect(ChatOps.get_mentioned_users("lorem ipsum @#{user1.handle} dolor sit")).to eq [user1]
    end

    it 'matches handles with contractions and possessive forms' do
      expect(ChatOps.get_mentioned_users("lorem ipsum @#{user1.handle}'s dolor sit")).to eq [user1]
      expect(ChatOps.get_mentioned_users("lorem ipsum #{user1.handle}'s dolor sit")).to eq [user1]
    end

    it 'matches handles case-insensitively' do
      expect(ChatOps.get_mentioned_users("lorem ipsum @#{user1.handle.upcase} dolor sit")).to eq [user1]
    end

    it 'de-duplicates users mentioned multiple times by handle' do
      expect(ChatOps.get_mentioned_users("lorem ipsum @#{user1.handle} dolor #{user1.handle} sit")).to eq [user1]
    end

    it 'returns multiple users mentioned by handles' do
      expect(ChatOps.get_mentioned_users("lorem ipsum @#{user1.handle} dolor #{user2.handle} sit")).to match_array([user1, user2])
    end

    let!(:john) { create(:user, name: "John Jones", handle: "john") }
    let!(:jsmith) { create(:user, name: "John Smith", handle: "jsmith") }
    let!(:jsj) { create(:user, name: "John Smith-Jones", handle: "jsj") }

    it 'returns users mentioned by full name' do
      # note that John Jones (whose handle is "john") is NOT returned here
      expect(ChatOps.get_mentioned_users("lorem ipsum John Smith dolor sit")).to eq [jsmith]
    end

    it 'matches full names case-insensitively' do
      expect(ChatOps.get_mentioned_users("lorem ipsum joHN SmItH dolor sit")).to eq [jsmith]
    end

    it 'matches full names without regard for whitespace' do
      expect(ChatOps.get_mentioned_users("lorem ipsum john  smith dolor sit")).to eq [jsmith]
    end

    it 'matches names with contractions and possessive forms' do
      expect(ChatOps.get_mentioned_users("lorem ipsum John Smith's here!")).to eq [jsmith]
    end

    it 'returns people mentioned by name and handle and de-duplicates' do
      expect(ChatOps.get_mentioned_users("lorem ipsum #{user1.name} dolor #{user2.name} sit #{user1.handle}")).to match_array([user1, user2])
    end

    it 'returns no users if none are mentioned' do
      expect(ChatOps.get_mentioned_users("lorem ipsum dolor sit amet")).to eq []
    end

    it 'does not let one name overshadow another' do
      # If "John Smith-Jones" is in the message, we need to make sure that he
      # is returned, not John Smith.
      expect(ChatOps.get_mentioned_users("lorem ipsum John Smith-Jones dolor sit")).to eq [jsj]
    end

    it 'does not match handles that are not whole words' do
      expect(ChatOps.get_mentioned_users("lorem ipsum qjsmith dolor sit")).to eq []
      expect(ChatOps.get_mentioned_users("lorem ipsum jsmithq dolor sit")).to eq []
    end

    it 'does not match names starting with an @ to allow explicitly matching a handle' do
      expect(ChatOps.get_mentioned_users("lorem ipsum @John Smith dolor sit")).to eq [john]
    end
  end

  describe ".prevent_highlights" do
    let(:turtle) { "\u{1f422}" }
    let(:separator) { "\u{2063}" }
    let!(:user1) { create(:user, handle: "foo") }

    it "should leave messages unchanged if they don't contain handles" do
      s = "lorem ipsum dolor sit amet"
      expect(ChatOps.prevent_highlights(s)).to eq s
    end

    it "should intersperse invisible separator into handles" do
      before = "lorem ipsum foo dolor sit amet"
      after = "lorem ipsum f#{separator}o#{separator}o dolor sit amet"
      expect(ChatOps.prevent_highlights(before)).to eq after
    end

    it "should work even for contractions" do
      before = "lorem ipsum foo're dolor sit amet"
      after = "lorem ipsum f#{separator}o#{separator}o're dolor sit amet"
      expect(ChatOps.prevent_highlights(before)).to eq after
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
        expect(ChatOps.parse_timestamp("5 minutes ago")).to eq(test_date - 5.minutes)
      end
    end


    it "handles times starting with 'at'" do
      Timecop.freeze(test_date) do
        expect(ChatOps.parse_timestamp("at 3pm")).to eq threepm_pdt
      end
    end

    it "handles times with time zones" do
      Timecop.freeze(test_date) do
        expect(ChatOps.parse_timestamp("3pm EDT")).to eq threepm_edt
        expect(ChatOps.parse_timestamp("3pm -0400")).to eq threepm_edt
      end
    end

    it "corrects 'EST' to 'EDT' during daylight time" do
      Timecop.freeze(date_in_dst) do
        expect(ChatOps.parse_timestamp("3pm EST")).to eq threepm_edt
      end
    end

    it "corrects 'EDT' to 'EST' during standard time" do
      Timecop.freeze(date_not_in_dst) do
        expect(ChatOps.parse_timestamp("3pm EDT")).to eq threepm_est
      end
    end
  end

  describe '.current_incident' do
    it "returns nil if no incidents have non-nil timeline_start" do
      create(:incident)
      expect(ChatOps.current_incident).to eq nil
    end

    it "returns the incident with the most recent timeline_start" do
      create(:incident, incident_id: 1, timeline_start: 5.minutes.ago)
      create(:incident, incident_id: 2, timeline_start: 10.minutes.ago)
      expect(ChatOps.current_incident.incident_id).to eq 1
    end
  end
end
