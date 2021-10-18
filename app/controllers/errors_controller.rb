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

class ErrorsController < ApplicationController
  def not_found
    render "greenlight_error", status: 404, formats: :html
  end

  def internal_error
    render "errors/greenlight_error", status: 500, formats: :html,
      locals: {
        status_code: 500,
        message: I18n.t("errors.internal.message"),
        help: I18n.t("errors.internal.help"),
        display_back: true,
        report_issue: true
      }
  end

  def unauthorized
    render "errors/greenlight_error", status: 401, formats: :html, locals: { status_code: 401,
      message: I18n.t("errors.unauthorized.message"), help: I18n.t("errors.unauthorized.help"), display_back: true }
  end
end
