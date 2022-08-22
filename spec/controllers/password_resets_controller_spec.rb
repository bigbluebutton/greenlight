# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

require "rails_helper"

def random_valid_user_params
  {
    user: {
      name: Faker::Name.first_name,
      email: Faker::Internet.email,
      password: "Example1!",
      password_confirmation: "Example1!",
      accepted_terms: false,
      email_verified: false,
    },
  }
end

describe PasswordResetsController, type: :controller do
  def by_pass_terms_acceptance
    old_terms = Rails.configuration.terms
    allow(Rails.configuration).to receive(:terms).and_return false
    res = yield
    allow(Rails.configuration).to receive(:terms).and_return(old_terms)
    res
  end

  before {
    allow(Rails.configuration).to receive(:terms).and_return('This is a dummy text!!')
    @user = by_pass_terms_acceptance { create(:user, accepted_terms: false) }
  }

  describe "POST #create" do
    context "allow mail notifications" do
      before {
        allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)
      }

      it "redirects to root url if email is sent" do
        allow(User).to receive(:find_by!).and_return(@user).with(hash_including(email: @user.email.downcase))
        params = {
          password_reset: {
            email: @user.email,
          },
        }
        expect(@user.reset_digest.nil? && @user.reset_sent_at.nil?).to be
        post :create, params: params
        expect(@user.reload.reset_digest.nil? || @user.reset_sent_at.nil?).not_to be
        expect(response).to redirect_to(root_path)
      end

      it "redirects to root with success flash if email does not exists" do
        params = {
          password_reset: {
            email: nil,
          },
        }

        post :create, params: params
        expect(@user.reload.reset_digest).to be_nil
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(root_path)
      end
    end

    context "reCAPTCHA enabled" do
      before do
        allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)
        allow(Rails.configuration).to receive(:recaptcha_enabled).and_return(true)
      end

      it "sends a reset email if the recaptcha was passed" do
        allow(controller).to receive(:valid_captcha).and_return(true)
        by_pass_terms_acceptance { @user.update provider: "greenlight" }

        params = {
          password_reset: {
            email: @user.email,
          },
        }

        expect { post :create, params: params }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "doesn't send an email if the recaptcha was failed" do
        allow(controller).to receive(:valid_captcha).and_return(false)
        params = {
          password_reset: {
            email: @user.email,
          },
        }

        post :create, params: params
        expect(response).to redirect_to(new_password_reset_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH #update" do
    before do
      allow(Rails.configuration).to receive(:enable_email_verification).and_return(true)
      @user = by_pass_terms_acceptance { create(:user, provider: "greenlight", accepted_terms: false) }
      @user1 = by_pass_terms_acceptance { create(:user, provider: "greenlight", accepted_terms: false) }
    end

    context "valid user" do
      before do
        freeze_time
        allow(controller).to receive(:check_expiration).and_return(nil)
        @before_one_sec_stamp = (Time.zone.now - 1.second).to_i
        session[:activated_at] = @before_one_sec_stamp
      end

      context "if the password update is NOT a success it" do
        def expectations(password:, password_confirmation:)
          params = {
            id: @user.create_reset_digest,
            user: {
              password: password,
              password_confirmation: password_confirmation,
            },
          }

          patch :update, params: params
          expect(session[:activated_at]).to eql(@before_one_sec_stamp)
          expect(flash[:alert]).to be_present
          expect(response).to render_template(:edit)
        end

        it "renders :edit page with notice when password is empty" do
          expectations(password: '', password_confirmation: '')
        end

        it "renders :edit page with notice when password confirmation mismatches" do
          expectations(password: 'Example1!', password_confirmation: 'NotAnExample1!')
        end
      end

      context "if the password update is a success" do
        def expectations(user_id: nil)
          session[:user_id] = user_id
          params = {
            id: @user.create_reset_digest,
            user: {
              password: "Example1!",
              password_confirmation: "Example1!",
            },
          }

          patch :update, params: params
          @user.reload

          expect(@user.last_pwd_update.to_i).to eql(Time.zone.now.to_i)
          expect(@user.reset_digest.nil? && @user.reset_sent_at.nil?).to be
          expect(@user.authenticate('Example1!')).to be_truthy
          expect(flash[:success]).to be_present
          expect(response).to redirect_to(root_path)
          yield
        end

        it "does NOT update :activated_at for unauthenticated reset requests" do
          expectations { expect(session[:activated_at]).to eql(@before_one_sec_stamp) }
        end
        context "for authenticated requests it" do
          it "update :activated_at when reset for the same authenticated user" do
            expectations(user_id: @user.id) { expect(session[:activated_at]).to eql(@user.last_pwd_update.to_i) }
          end
        end
        it "does not update :activated_at when reset from another user" do
          expectations(user_id: @user1.id) { expect(session[:activated_at]).to eql(@before_one_sec_stamp) }
        end
      end
    end
  end
end
