class NotificationsMailer < ApplicationMailer

  def retro_followup(incident:, sender:, to:, cc:, subject:)
    @incident = incident
    mail(
      sender:  sender,
      to:      to,
      cc:      cc,
      subject: subject
    )
  end

end
