# frozen_string_literal: true

class LocalesController < ApplicationController
  def show
    language = params[:name].tr('-', '_')

    render json: File.read(Rails.root.join('app', 'assets', 'locales', "#{language}.json"))
  rescue StandardError
    head :not_acceptable
  end
end
