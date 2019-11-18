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

module Deleteable
  extend ActiveSupport::Concern

  included do
    # By default don't include deleted if the column has been created
    default_scope { where(deleted: false) } if column_names.include? 'deleted'
    scope :include_deleted, -> { unscope(where: :deleted) }
    scope :deleted, -> { include_deleted.where(deleted: true) }
  end

  def destroy(permanent = false)
    if permanent
      super()
    else
      run_callbacks :destroy do end
      update_attribute(:deleted, true)
    end
  end

  def delete(permanent = false)
    destroy(permanent)
  end

  def undelete!
    update_attribute(:deleted, false)
  end

  def permanent_delete
    destroy(true)
  end

  def deleted?
    deleted
  end
end
