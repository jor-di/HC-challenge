# frozen_string_literal: true

EMAIL_PATTERN = /\A[^@]+@[^@.]+[.][a-zA-Z]+\z/.freeze
# ITS phone numbers. https://www.regextester.com/1978
PHONE_NUMBER_PATTERN = /\A((?:\+|00)[17](?: |\-)?|(?:\+|00)[1-9]\d{0,2}(?: |\-)?|(?:\+|00)1\-\d{3}(?: |\-)?)?(0\d|\([0-9]{3}\)|[1-9]{0,3})(?:((?: |\-)[0-9]{2}){4}|((?:[0-9]{2}){4})|((?: |\-)[0-9]{3}(?: |\-)[0-9]{4})|([0-9]{7}))\z/.freeze

REQUEST_EXPIRING_DELAY = 3.months
REQUEST_EXPIRING_DELAY_EXTRA_DURATION = 7.days
CONTRACT_DURATION = 1.month

class Request < ApplicationRecord
  scope :unconfirmed, -> { where(email_confirmed_date: nil) }
  scope :confirmed, -> { where.not(email_confirmed_date: nil).where(contract_starting_date: nil, expired: false).order(:email_confirmed_date) }
  scope :accepted, -> { where.not(contract_starting_date: nil) }
  scope :expired, -> { where(expired: true) }
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
    save!
  end

  def confirm_email!
    self.email_confirmed_date = Time.now
    save!
  end

  def update_expiring_date!
    self.request_expiring_date = Date.today + REQUEST_EXPIRING_DELAY
    save!
  end

  def waiting_list_position
    Request.confirmed.pluck(:id).index(id) + 1
  end

  def waiting_list_position_to_text
    "You are on the #{waiting_list_position.ordinalize} position on the waiting list."
  end

  def contract_ending_date
    contract_starting_date + CONTRACT_DURATION
  end

  def self.reconfirm_requests
    today = Date.today
    Request.confirmed.all.each do |request|
      if request.request_expiring_date == today # double equal and not superior to to avoid multiple sendings over the passing days
        request.send_renew_expiring_date_email
      elsif request.request_expiring_date + REQUEST_EXPIRING_DELAY_EXTRA_DURATION < today
        request.expired!
      end
    end
  end

  def self.renew_contracts
    today = Date.today
    Request.accepted.all.each do |request|
      if request.contract_ending_date <= today
        request.contract_starting_date = today
        request.save!
      end
    end
  end

  def send_renew_expiring_date_email
    RequestMailer.renew_expiring_date(self).deliver_now
  end

  private

  def send_confirmation_email
    RequestMailer.email_confirmation(self).deliver_now
  end
end
