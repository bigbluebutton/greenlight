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

def uri?(string)
  uri = URI.parse(string)
  %w( http https ).include?(uri.scheme)
rescue URI::BadURIError
  false
rescue URI::InvalidURIError
  false
end

if !ENV['SLACK_WEBHOOK'] || !ENV['SLACK_CHANNEL'] || !uri?(ENV['SLACK_WEBHOOK']) then
  # Initialize it to nil (slack not configured)
  Rails.application.config.slack_notifier = nil
  return
end

# Initialize the slack notifier.
Rails.application.config.slack_notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK'] do
  defaults channel: ENV['SLACK_CHANNEL'],
           username: "BigBlueButton",
           icon_url: 'https://avatars3.githubusercontent.com/u/230228?v=3&s=200'
end
