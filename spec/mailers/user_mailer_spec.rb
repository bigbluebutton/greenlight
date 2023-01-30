# frozen_string_literal: true

require 'rails_helper'

describe UserMailer, type: :mailer do
  describe '#reset_password_email' do
    it 'sets correct reset mail message' do
      freeze_time
      user = build(:user)

      mail = described_class.with(user:, reset_url: 'https://reset.password.now/token', expires_in: 1.day.from_now).reset_password_email

      expect(mail.subject).to eq 'Password Reset Request'
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to match(user.email)
      expect(mail.body.encoded).to match('href="https://reset.password.now/token"')
      expect(mail.body.encoded).to match('The link will expire in 1 day.')
    end
  end

  describe '#activate_account_email' do
    it 'sets correct activation mail message' do
      freeze_time
      user = build(:user)

      mail = described_class.with(user:, activation_url: 'https://activate.account.now/token', expires_in: 1.day.from_now).activate_account_email

      expect(mail.subject).to eq 'Account Activation'
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to match('href="https://activate.account.now/token"')
      expect(mail.body.encoded).to match('The link will expire in 1 day.')
    end
  end

  describe '#test_email' do
    it 'sets correct test mail message' do
      mail = described_class.with(to: 'user@users.com', subject: 'Test Subject').test_email

      expect(mail.subject).to eq 'Test Subject'
      expect(mail.to).to eq(['user@users.com'])
    end
  end
end
