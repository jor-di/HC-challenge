require 'rails_helper'

VALID_EMAIL = 'john@doe.com'

RSpec.describe Request, type: :model do
  context 'When creating a request instance' do
    subject(:a_request) do
      described_class.new(name: 'John Doe', email: VALID_EMAIL, phone_number: '0399190139',
                          biography: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.')
    end

    it 'should be valid with valid arguments' do
      expect(a_request).to be_valid
    end
    # missing parameters
    it 'should not be valid with a name missing' do
      a_request.name = nil
      expect(a_request).to_not be_valid
    end
    it 'should not be valid with an email missing' do
      a_request.email = nil
      expect(a_request).to_not be_valid
    end
    it 'should not be valid with a phone number missing' do
      a_request.phone_number = nil
      expect(a_request).to_not be_valid
    end
    it 'should not be valid with a biography missing' do
      a_request.biography = nil
      expect(a_request).to_not be_valid
    end
    # incorrect formats
    it 'should not be valid with an incorrect phone number format' do
      fake_phone_numbers = %w[123 fakephonenumber]
      fake_phone_numbers.each do |fake_phone_number|
        a_request.phone_number = fake_phone_number
        expect(a_request).to_not be_valid
      end
    end
    it 'should not be valid with an incorrect email format' do
      fake_emails = %w[fakeemail fake@email]
      fake_emails.each do |fake_email|
        a_request.email = fake_email
        expect(a_request).to_not be_valid
      end
    end
    it 'should not be valid with a too short biography' do
        a_request.biography = 'abcdefghi (19chars)'
        expect(a_request).to_not be_valid
    end

    it 'should have date attributes set to nil' do
      expect(a_request.email_confirmed_date).to be_nil
      expect(a_request.request_expiring_date).to be_nil
      expect(a_request.contract_starting_date).to be_nil
    end

    it 'should not allow duplicate emails of 2 unexpired requests' do
      a_request.save
      another_request = Request.new(name: 'another name', email: VALID_EMAIL, phone_number: '0610101010',
                  biography: 'another valid biography')
      another_request.valid?
      expect(another_request.errors[:email]).to include("has already been taken")
    end

    it 'should allow duplicate emails if one of the two requests is expired' do
      a_request.expired!
      another_request = Request.new(name: 'another name', email: VALID_EMAIL, phone_number: '0610101010',
                  biography: 'another valid biography')
      another_request.valid?
      expect(another_request).to be_valid
    end
  end
end
