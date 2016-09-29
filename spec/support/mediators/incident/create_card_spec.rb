RSpec.describe Mediators::Incident::CreateCard do
  let!(:trello_url) { "https://trello.com/c/AbCdEfG" }
  let!(:incident) { create(:incident) }
  let!(:user)     { create(:user, :trello_oauth) }

  describe "#call" do
    before do
      @template = instance_double("template", id: 250, list_id: 20)
      @trello = instance_double("trello", find: @template, create: :card)

      allow(Trello::Client).to receive(:new).and_return(@trello)
      allow(@trello).to receive(:create).and_return(trello_url)
    end

    it 'Creates a card ' do
      expect(Mediators::Incident::CreateCard).to receive(:run).and_return(trello_url)

      Mediators::Incident::CreateCard.run(
        id: incident.id,
        title: incident.title,
        trello_oauth_token: user.trello_oauth_token,
        trello_oauth_secret: user.trello_oauth_secret
      )
    end

    it 'throws and exception' do
      allow(Trello::Client).to receive(:new).and_raise(Trello::InvalidAccessToken)

      expect {
        Mediators::Incident::CreateCard.run(
        id: incident.id,
        title: incident.title,
        trello_oauth_token: nil,
        trello_oauth_secret: nil
        )
      }.to raise_error(Trello::InvalidAccessToken)
    end
  end
end
