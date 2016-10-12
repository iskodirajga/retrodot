RSpec.describe NotificationsMailer, type: :mailer do

  let!(:incident) { create(:incident, started_at: Time.now) }

  describe "#retro_followup" do

    subject {
        NotificationsMailer.retro_followup(
          incident: incident,
          sender:   'foo@retrodot.com',
          to:       'bar@retrodot.com',
          subject:  'Retrodot is coming!',
          cc:       'baz@retrodot.com'
        ).deliver_now
    }

    before do
      subject
    end

    it "delivers mail" do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it "is from foo@retrodot.com" do
      expect(subject.sender).to eq "foo@retrodot.com"
    end

    it "is to bar@retrodot.com" do
      expect(subject.to.first).to eq "bar@retrodot.com"
    end

    it "has cc" do
      expect(subject.cc.first).to eq "baz@retrodot.com"
    end

    it "has subject" do
      expect(subject.subject).to eq "Retrodot is coming!"
    end
  end
end
