# frozen_string_literal: true

EMAIL_PATTERN = /\A[^@]+@[^@.]+[.][a-zA-Z]+\z/
# ITS phone numbers. https://www.regextester.com/1978
PHONE_NUMBER_PATTERN = /\A((?:\+|00)[17](?: |\-)?|(?:\+|00)[1-9]\d{0,2}(?: |\-)?|(?:\+|00)1\-\d{3}(?: |\-)?)?(0\d|\([0-9]{3}\)|[1-9]{0,3})(?:((?: |\-)[0-9]{2}){4}|((?:[0-9]{2}){4})|((?: |\-)[0-9]{3}(?: |\-)[0-9]{4})|([0-9]{7}))\z/

class Request < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: EMAIL_PATTERN }
  validates :biography, presence: true, length: { minimum: 20 }
  validates :phone_number, presence: true, format: { with: PHONE_NUMBER_PATTERN }
  validates_uniqueness_of :email, conditions: -> { where(expired: false) } # this to ensure a user can re-subscribe with the same email if his first request has expired
  validates_inclusion_of :expired, in: [false], if: :contract_starting_date, message: "cannot be false for the request to be accepted"
  validates_exclusion_of :email_confirmed_date, in: [nil], if: :contract_starting_date, message: "cannot be nil for the request to be accepted"
  after_create :send_confirmation_email

  def accept!
    self.contract_starting_date = Date.today
    self.request_expiring_date = nil
    save!
  end

  def expired!
    self.expired = true
    save
  end

  def confirm_email!
    self.email_confirmed_date = Time.now
    save
  end

  def update_expiring_date!
    self.request_expiring_date = Date.today + 3.months
    save
  end

  private

  def send_confirmation_email
    RequestMailer.email_confirmation(self).deliver_now
  end
end
