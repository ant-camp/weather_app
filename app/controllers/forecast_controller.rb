# frozen_string_literal: true

class ForecastController < ApplicationController
  def index
    @address = address_params || 'Tampa, FL'
    weather_data = ForecastService.new(@address).get_weather_data

    if weather_data.present?
      set_weather_data(weather_data)
      @from_cache = cached_weather_data?(@address)
    else
      flash[:alert] = 'Unable to fetch weather data for the given address.'
      render :index
    end
  end

  private

  def address_params
    params[:address]
  end

  def set_weather_data(weather_data)
    @current_temperature = weather_data['main']['temp']
    @high_temperature = weather_data['main']['temp_max']
    @low_temperature = weather_data['main']['temp_min']
  end

  def cached_weather_data?(address)
    Rails.cache.exist?("weather_data_#{address}")
  end
end
