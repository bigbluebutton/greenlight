# frozen_string_literal: true

class PublicRoomSerializer < ApplicationSerializer
  attributes :name, :viewer_access_code, :moderator_access_code

  def viewer_access_code
    @instance_options[:options][:access_codes]['glViewerAccessCode']
  end

  def moderator_access_code
    @instance_options[:options][:access_codes]['glModeratorAccessCode']
  end
end
