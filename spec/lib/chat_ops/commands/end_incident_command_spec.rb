RSpec.describe ChatOps::Commands::EndIncidentCommand do
  include ChatOpsCommandHelper

  describe "regex" do
    test_regex_against_commands <<-EOL
      end incident
      end the incident
      end incident 12
    EOL
  end

  describe ".run" do
    command :end_incident

    let(:incident) { create(:incident) }

    it "returns an error if no incidents exist" do
      expect(end_incident).to return_response_matching /unknown incident/
    end

    it "returns an error if no incidents have had their timelines started" do
      create(:incident)
      expect(end_incident).to return_response_matching /unknown incident/
    end

    it "sets the chat_end for the current incident" do
      Timecop.freeze do
        set_current_incident incident
        end_incident
        expect(current_incident.chat_end).to match_to_the_millisecond Time.now
      end
    end

    it "says that it has recorded the end of chat" do
      set_current_incident incident
      expect(end_incident).to return_response_matching /Recorded the end of chat for incident/
    end
  end
end
