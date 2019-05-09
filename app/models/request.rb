# frozen_string_literal: true

EMAIL_PATTERN = /\A[^@]+@[^@.]+[.][a-zA-Z]+\z/
# ITS phone numbers. https://www.regextester.com/1978
PHONE_NUMBER_PATTERN = /\A((?:\+|00)[17](?: |\-)?|(?:\+|00)[1-9]\d{0,2}(?: |\-)?|(?:\+|00)1\-\d{3}(?: |\-)?)?(0\d|\([0-9]{3}\)|[1-9]{0,3})(?:((?: |\-)[0-9]{2}){4}|((?:[0-9]{2}){4})|((?: |\-)[0-9]{3}(?: |\-)[0-9]{4})|([0-9]{7}))\z/

class Request < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: EMAIL_PATTERN }
  validates :biography, presence: true, length: { minimum: 20 }
  validates :phone_number, presence: true, format: { with: PHONE_NUMBER_PATTERN }
  after_create :send_confirmation_email

  def expired!
    self.expired = true
    save
  end

  def confirm_email!(time)
    self.email_confirmed_date = time
    save
  end

  def update_expiring_date!(date)
    self.request_expiring_date = date + 3.months
    save
  end

  private

  def send_confirmation_email
    RequestMailer.email_confirmation(self).deliver_now
  end
end
