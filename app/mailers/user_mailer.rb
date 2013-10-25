class UserMailer < ActionMailer::Base
  @@url = "http://kreyos.nesventures.net"
  @@admin_email = "NESVkreyos@gmail.com"
  @@contact_us_email = "mcerezo@nesventures.com"

  #contact us mailer
  def contact_us(email, subject, message)
    @email = email
    @subject = subject
    @message = message
    @url = @@url
    mail(:to => "#{@@contact_us_email}", :subject => "#{subject}")
  end
  
  def invite_friend(recipient_email, recipient_name, sender_email)
    @recipient_name = recipient_name
    @sender = sender_email
    @subject = "Kreyos Friend Invitation"
    mail(:to => "#{recipient_email}", :subject => "#{@subject}")
  end
end
