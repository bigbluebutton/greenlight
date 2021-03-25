class InsideRoomController < ApplicationController
  include Registrar

  # GET /inside
  def inside
    @cache_expire = 10.seconds
    @target_url_client = session['target_url_client']
    @current_room_inside = session['current_room_inside']
    @is_neelz_room = session['is_neelz_room']
    @is_moderator = @is_neelz_room && session['is_moderator'] && session['moderator_for'] == @current_room_inside
    session['is_moderator'] = @is_moderator
    @interviewer_browses = @is_neelz_room && session['neelz_interviewer_browses'] == 1
    @proband_co_browses = @is_neelz_room && session['neelz_proband_co_browses'] == 1
    @user_browses = @is_moderator && @interviewer_browses || @proband_co_browses
  end

end