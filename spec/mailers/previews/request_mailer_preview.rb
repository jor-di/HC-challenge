# Preview all emails at http://localhost:3000/rails/mailers/request_mailer
class RequestMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/request_mailer/email_confirmation
  def email_confirmation
    request = Request.first
    RequestMailer.email_confirmation(request)
  end

  def renew_expiring_date
    request = Request.first
    RequestMailer.renew_expiring_date(request)
  end

end
