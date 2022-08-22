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

describe MainController, type: :controller do
  describe "GET #index" do
    it "should have a  successful response for unauthenticated users" do
      expect(session[:user_id]).to be_nil
      get :index
      expect(response).to be_successful
    end

    context "redirects signed in user" do
      before do
        @user = create(:user)
        session[:user_id] = @user.id
        freeze_time
      end

      context "to main room for valid sessions" do
        def expectations(expected_activated_at: Time.zone.now)
          expect(session[:user_id]).to eql(@user.id)
          yield
          get :index
          expect(session[:activated_at]).to eql(expected_activated_at.to_i)
          expect(response).to redirect_to(@user.main_room)
        end

        context "for accounts with no password updates" do
          it "and with nil activated_at" do
              expectations {
                expect(session[:activated_at].nil? && @user.last_pwd_update.nil?).to be
              }
          end
          it "and with alerady updated activated_at" do
            before_one_hour_stamp = (Time.zone.now - 1.hour).to_i

            expectations(expected_activated_at: before_one_hour_stamp) {
              session[:activated_at] = before_one_hour_stamp
              expect(session[:activated_at].present? && @user.last_pwd_update.nil?).to be
            }
          end
        end
        it "after a password update" do
          expectations {
            @user.update last_pwd_update: Time.zone.now
            session[:activated_at] = @user.last_pwd_update.to_i
            expect(session[:activated_at].present? && @user.last_pwd_update.present?).to be
          }
        end
      end

      context "to root path for invalid sessions" do
        def expectations
          expect(session[:user_id]).to eql(@user.id)
          yield
          get :index
          expect(session[:user_id].nil? && session[:activated_at].nil?).to be
          expect(flash[:alert]).to be_present
          expect(response).to redirect_to(root_path)
        end

        before do
          @user.update last_pwd_update: Time.zone.now
        end

        it "with nil activated_at" do
          expectations {
            expect(session[:activated_at].nil? && @user.last_pwd_update.present?).to be
          }
        end
        it "with active sessions before latest password update" do
          expectations {
            session[:activated_at] = @user.last_pwd_update.to_i - 1
            expect(session[:activated_at].present? && @user.last_pwd_update.present?).to be
          }
        end
      end
    end
  end
end
