class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name($APP_EMAIL, 'Allegra Dept Store')
  layout 'mailer'
end
