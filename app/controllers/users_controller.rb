# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
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

class UsersController < ActionController::Base

  # For updating a users background image.
  def update

    # Make sure they actually select a file.
    if params[:user] then
      @user = User.find(params[:id])
      @user.assign_attributes(background: user_params[:background])
      flash[:danger] = t('invalid_file') unless @user.save
    else
      flash[:danger] = t('no_file')
    end

    # Reload the page to apply changes and show flash messages.
    redirect_back(fallback_location: root_path)
  end

  private

  def user_params
    params.require(:user).permit(:background)
  end

end
