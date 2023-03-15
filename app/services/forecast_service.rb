# frozen_string_literal: true

require 'json'
require 'open-uri'

class ForecastService
  WEATHER_BASE_URL = ENV['WEATHER_BASE_URL']

  def initialize(address)
    @address = address
  end

  def get_weather_data
    return cached_weather_data if cached_weather_data.present?

    weather_data = fetch_weather_data
    cache_weather_data(weather_data)
    weather_data
  end

  private

  def cached_weather_data
    cached_data = Rails.cache.read(cache_key)
    JSON.parse(cached_data) if cached_data.present?
  end

  def fetch_weather_data

    data = fetch_geo_location_data
    return nil unless data.present? && data['lat'].present? && data['lon'].present?

    lat = data['lat']
    lon = data['lon']
    fetch_weather_details(lat, lon)
  end

  def fetch_geo_location_data
    url = "#{WEATHER_BASE_URL}/geo/1.0/direct?q=#{URI.encode_www_form_component(@address)}&limit=1&appid=#{api_key}"
    response = URI.open(url).read
    JSON.parse(response).first
  end

  def fetch_weather_details(lat, lon)
    url = "#{WEATHER_BASE_URL}/data/2.5/weather?lat=#{lat}&lon=#{lon}&appid=#{api_key}&units=metric"
    response = open(url).read
    JSON.parse(response)
  end

  def cache_weather_data(weather_data)
    Rails.cache.write(cache_key, weather_data.to_json, expires_in: 30.minutes)
  end

  def cache_key
    "weather_data_#{@address}"
  end

  def api_key
    ENV['API_KEY']
  end
end
