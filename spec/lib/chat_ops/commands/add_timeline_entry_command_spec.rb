RSpec.describe ChatOps::Commands::AddTimelineEntryCommand do
  include ChatOpsCommandHelper

  describe 'regex' do
    it_should_match_commands <<-EOL
      timeline foo
      timeline foo bar baz
      timeline 12 foo
      timeline 12 foo bar baz
      timeline 1is the loneliest number
    EOL

    it_should_not_match_commands <<-EOL
      timeline 12
    EOL
  end

  describe '.run' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let!(:incident) { create(:incident,
                            open: true,
                            chat_start: 10.minutes.ago,
                            timeline_start: 10.minutes.ago)
                   }
    let!(:other_incident) { create(:incident,
                                  open: true,
                                  chat_start: 20.minutes.ago,
                                  timeline_start: 20.minutes.ago)
                         }
    let(:message1) { "this is a timeline entry" }
    let(:message_with_mentions) { "timeline entry with #{user1.handle} and #{user2.name}" }

    it "should add an entry to the timeline" do
      Timecop.freeze do
        expect(process("timeline #{message1}", user1)).to message_with(':checkmark:')
        expect(incident.timeline_entries).to have(1).items
        expect(incident.timeline_entries[0].message).to eq message1
        expect(incident.timeline_entries[0].user).to be_same_as user1
        expect(incident.timeline_entries[0].timestamp).to match_to_the_millisecond Time.now
      end
    end

    it "should add an entry to the specified incident" do
      process("timeline #{other_incident.incident_id} #{message1}")
      expect(incident.timeline_entries).to be_empty
      expect(other_incident.timeline_entries).to have(1).items
    end

    it "should add the user running the command to the incident" do
      process("timeline #{message1}", user1)
      expect(incident.responders).to include user1
    end

    it "should add mentioned users to the incident's responders list" do
      process("timeline #{message_with_mentions}")
      expect(incident.responders).to include(user1, user2)
    end
  end
end
