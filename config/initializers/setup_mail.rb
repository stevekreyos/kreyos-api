ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "kreyos.nesventures.net",
  :user_name            => "noreply.kreyos",
  :password             => "patches214",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = "kreyos.nesventures.net"