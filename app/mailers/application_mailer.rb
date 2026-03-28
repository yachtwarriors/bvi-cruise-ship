class ApplicationMailer < ActionMailer::Base
  default from: '"BVI Cruise Ship Schedule" <alerts@bvicruiseshipschedule.com>'
  layout "mailer"
end
