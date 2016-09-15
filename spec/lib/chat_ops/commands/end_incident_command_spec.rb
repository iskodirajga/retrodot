RSpec.describe ChatOps::Commands::EndIncidentCommand do
  describe "regex" do
    let(:regex) {  }

    example_commands = <<-EOL.each_line.map(&:strip)
    end incident
    end the incident
    end incident 12
    EOL

    subject { ChatOps::Commands::EndIncidentCommand.regex }

    example_commands.each do |command|
      it { is_expected.to match command }
    end
  end

  describe ".run" do
    let(:end_incident_command) { ChatOps::Commands::EndIncidentCommand.new }
    let(:user) { create(:user) }

    def process(command)
      end_incident_command.process(user, command)
    end

    def end_incident(arg="")
      process("end incident #{arg}")
    end

    it "returns an error if no incidents exist" do
      expect(end_incident[:message]).to match /unknown incident/
    end
  end
end
