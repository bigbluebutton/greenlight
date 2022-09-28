# frozen_string_literal: true

class CurrentRoomSerializer < ApplicationSerializer
  include Presentable
  include Avatarable

  attributes :id, :name, :presentation_name, :thumbnail

  attribute :owner_name, if: -> { @instance_options[:options][:include_owner] }
  attribute :owner_avatar, if: -> { @instance_options[:options][:include_owner] }
  attribute :last_session, if: -> { object.last_session }

  def presentation_name
    presentation_file_name(object)
  end

  def thumbnail
    presentation_thumbnail(object)
  end

  def owner_name
    object.user.name
  end

  def owner_avatar
    user_avatar(object.user)
  end

  def last_session
    object.last_session.strftime('%B %e, %Y %l:%M%P')
  end
end
