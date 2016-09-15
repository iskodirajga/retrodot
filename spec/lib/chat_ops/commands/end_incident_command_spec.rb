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

    it "returns an error if no incidents exist" do
      expect(end_incident()[:message]).to match /unknown incident/
    end
  end
end
