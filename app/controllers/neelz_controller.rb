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
require 'date'

class NeelzController < ApplicationController
  include Pagy::Backend
  include Recorder
  include Joiner
  include Populator
  include Emailer

  # GET /neelz/gate
  def gate
    @cache_expire = 10.seconds
    unless params[:qvid].present? && params[:name_of_study].present?
      return redirect_to('/', alert: 'invalid request')
    end
    @qvid = params[:qvid].to_i(10)
    @name_of_study = params[:name_of_study]
    @neelz_room = NeelzRoom.get_room(qvid: @qvid, name_of_study: @name_of_study)
    @neelz_room.set_interviewer_name(params[:interviewer_name]) if params[:interviewer_name].present?
    @neelz_room.set_interviewer_url(params[:interviewer_url]) if params[:interviewer_url].present?
    @neelz_room.set_interviewer_browses(params[:interviewer_url].present?)
    @neelz_room.set_co_browsing_externally_triggered(params[:co_browsing_externally_triggered].to_i(10) === 1) if params[:co_browsing_externally_triggered].present?
    @neelz_room.set_proband_url(params[:proband_url]) if params[:proband_url].present?
    @neelz_room.set_proband_browses(params[:proband_url].present? || @neelz_room.co_browsing_externally_triggered?)
    @neelz_room.set_proband_alias(params[:proband_alias]) if params[:proband_alias].present?
    @neelz_room.set_interviewer_screen_split_mode_on_login(params[:interviewer_screen_split_mode_on_login].to_i(10)) if params[:interviewer_screen_split_mode_on_login].present?
    @neelz_room.set_proband_screen_split_mode_on_login(params[:proband_screen_split_mode_on_login].to_i(10)) if params[:proband_screen_split_mode_on_login].present?
    @neelz_room.set_proband_screen_split_mode_on_share(params[:proband_screen_split_mode_on_share].to_i(10)) if params[:proband_screen_split_mode_on_share].present?
    @neelz_room.set_external_frame_min_width(params[:external_frame_min_width]) if params[:external_frame_min_width].present?
    @neelz_room.set_show_participants_on_login(params[:show_participants_on_login].to_i(10) === 1) if params[:show_participants_on_login].present?
    @neelz_room.set_show_chat_on_login(params[:show_chat_on_login].to_i(10) === 1) if params[:show_chat_on_login].present?
    @neelz_room.set_always_record(params[:always_record].to_i(10) === 1) if params[:always_record].present?
    @neelz_room.set_allow_start_stop_record(params[:allow_start_stop_record].to_i(10) === 1) if params[:allow_start_stop_record].present?
    @neelz_room.set_proband_readonly(true) if params[:proband_readonly].present? && params[:proband_readonly].to_i(10) === 1
    @neelz_room.save
    session[:neelz_qvid] = @qvid
    session[:neelz_join_name] = cookies.encrypted[:greenlight_name] = @neelz_room.interviewer_name
    session[:neelz_role] = 'interviewer'
    session[:neelz_interviewer_for] = @neelz_room.uid
    session[:access_code] = @neelz_room.access_code
    redirect_to 'neelz'
  end

  # GET /neelz/cgate/:proband_qvid
  def cgate
    @cache_expire = 10.seconds
    @qvid = session[:neelz_qvid] = NeelzRoom.decode_proband_qvid(params[:proband_qvid])
    @neelz_room = NeelzRoom.get_room(qvid: @qvid)
    return redirect_to('/', alert: 'invalid request') unless @neelz_room
    session[:neelz_join_name] = cookies.encrypted[:greenlight_name] = @neelz_room.proband_alias
    session[:neelz_role] = 'proband'
    redirect_to @neelz_room.uid
  end

  # GET /neelz
  def preform
    @cache_expire = 10.seconds
    @neelz_room = NeelzRoom.get_room(qvid: session[:neelz_qvid])
    return redirect_to('/', alert: 'invalid request') unless @neelz_room
    @neelz_interviewer_name = @neelz_room.interviewer_name
    @neelz_name_of_study = @neelz_room.name_of_study
    @neelz_proband_access_url = @neelz_room.proband_access_url
    @neelz_room_access_code = @neelz_room.access_code
    @neelz_proband_name = @neelz_room.proband_alias || ''
    @neelz_proband_email = session[:neelz_proband_email] || ''
  end

  # POST /neelz/waiting
  def waiting
    @cache_expire = 10.seconds
    @neelz_proband_name = params[:session][:name_proband]
    @neelz_proband_email = params[:session][:email_proband]
    @neelz_room = NeelzRoom.get_room(qvid: session[:neelz_qvid])
    return redirect_to 'neelz' unless @neelz_room
    @neelz_room.set_proband_alias(@neelz_proband_name)
    @neelz_room.save
    @neelz_proband_access_url = @neelz_room.proband_access_url
    @neelz_room_access_code = @neelz_room.access_code
    @neelz_interviewer_name = @neelz_room.interviewer_name
    @neelz_name_of_study = @neelz_room.name_of_study
    if (@neelz_proband_email.length >= 7) && (@neelz_proband_email.include? "@")
      send_neelz_participation_email(@neelz_proband_email,@neelz_proband_access_url,
                                     @neelz_room_access_code,@neelz_interviewer_name,
                                     @neelz_proband_name,@neelz_name_of_study)
    end
    redirect_to @neelz_room.uid
  end

  # POST /neelz/share
  def share
    @cache_expire = 5.seconds
    @neelz_room = NeelzRoom.get_room(qvid: session[:neelz_qvid])
    return redirect_to('/', alert: 'invalid request') unless @neelz_room
    NotifyCoBrowsingJob.set(wait: 0.seconds).perform_later(@neelz_room)
  end

  # POST /neelz/i_share
  def i_share
    @cache_expire = 5.seconds
    @neelz_room = NeelzRoom.get_room(qvid: session[:neelz_qvid])
    return redirect_to('/', alert: 'invalid request') unless @neelz_room
    login = params[:l]
    password = params[:c]
    proband_url_new = "#{Rails.configuration.neelz_i_share_base_url}/i_cb/?login=#{login}&password=#{password}&send=1"
    proband_url = @neelz_room.proband_url
    unless proband_url == proband_url_new
      @neelz_room.set_proband_url(proband_url_new)
      @neelz_room.save
    end
    NotifyCoBrowsingJob.set(wait: 0.seconds).perform_later(@neelz_room)
  end

  # POST /neelz/unshare
  def unshare
    @cache_expire = 5.seconds
    @neelz_room = NeelzRoom.get_room(qvid: session[:neelz_qvid])
    return redirect_to('/', alert: 'invalid request') unless @neelz_room
    NotifyCoBrowsingUnshareJob.set(wait: 0.seconds).perform_later(@neelz_room)
  end

  # POST /neelz/refresh
  def refresh
    @cache_expire = 5.seconds
    @neelz_room = NeelzRoom.get_room(qvid: session[:neelz_qvid])
    return redirect_to('/', alert: 'invalid request') unless @neelz_room
    NotifyCoBrowsingRefreshJob.set(wait: 0.seconds).perform_later(@neelz_room)
  end

  # GET /neelz/thank_you/:qvid @TODO: implement
  def thank_you
    session[:neelz_qvid] = decode_proband_qvid(params[:qvid])
    @neelz_room = NeelzRoom.get_room(qvid: session[:neelz_qvid])
    return redirect_to('/', alert: 'invalid_request') unless @neelz_room

  end

  # GET /neelz/i_inside
  def i_inside
    @cache_expire = 10.seconds
    return redirect_to('/', alert: 'invalid request') unless session[:target_url_client].present?
    return redirect_to('/', alert: 'invalid request') unless session[:neelz_qvid].present?
    return redirect_to('/', alert: 'invalid request') unless session[:neelz_role] == 'interviewer'
    room = NeelzRoom.get_room(qvid: session[:neelz_qvid])
    if room && NeelzRoom.is_neelz_room?(room)
      @neelz_room = NeelzRoom.convert_to_neelz_room(room)
      @target_url_client = session[:target_url_client]
      @user_browses = @neelz_room.interviewer_browses?
      @neelz_role = 'interviewer'
    else
      redirect_to('/', alert: 'invalid_request')
    end
  end

  # GET /neelz/p_inside
  def p_inside
    @cache_expire = 10.seconds
    return redirect_to('/', alert: 'invalid request') unless session[:target_url_client].present?
    return redirect_to('/', alert: 'invalid request') unless session[:neelz_qvid].present?
    return redirect_to('/', alert: 'invalid request') unless session[:neelz_role] == 'proband'
    room = NeelzRoom.get_room(qvid: session[:neelz_qvid])
    if room && NeelzRoom.is_neelz_room?(room)
      @neelz_room = NeelzRoom.convert_to_neelz_room(room)
      @target_url_client = session[:target_url_client]
      @user_browses = @neelz_room.proband_browses?
      @neelz_role = 'proband'
    else
      redirect_to('/', alert: 'invalid_request')
    end
  end


end
