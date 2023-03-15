# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ForecastService, type: :service do
  let(:address) { '123 Main St, Springfield' }
  let(:service) { ForecastService.new(address) }
  let(:geo_location_data) { { 'lat' => 40.0, 'lon' => -75.0 } }
  let(:weather_data) { { 'weather' => 'clear', 'temp' => 25.0 } }

  before do
    allow(ENV).to receive(:[]).with('WEATHER_BASE_URL').and_return('http://test-weather-api.com')
    allow(ENV).to receive(:[]).with('API_KEY').and_return('test-api-key')
  end

  describe '#get_weather_data' do
    context 'when weather data is cached' do
      it 'returns cached weather data' do
        allow(Rails.cache).to receive(:read).with("weather_data_#{address}").and_return(weather_data.to_json)

        expect(service.get_weather_data).to eq(weather_data)
      end
    end

    context 'when weather data is not cached' do
      before do
        allow(Rails.cache).to receive(:read).with("weather_data_#{address}").and_return(nil)
        allow(service).to receive(:fetch_weather_data).and_return(weather_data)
        allow(service).to receive(:cache_weather_data).with(weather_data)
      end

      it 'fetches and caches the weather data' do
        expect(service).to receive(:fetch_weather_data)
        expect(service).to receive(:cache_weather_data).with(weather_data)

        expect(service.get_weather_data).to eq(weather_data)
      end
    end
  end

  describe 'private methods' do
    context '#fetch_geo_location_data' do
      let(:converted_geo_location_data) { ['lat', 40.0] }
      it 'returns geo location data' do
        url = "http://api.openweathermap.org/geo/1.0/direct?q=#{URI.encode_www_form_component(address)}&limit=1&appid=test-api-key"
        allow(URI).to receive(:open).with(url).and_return(StringIO.new(geo_location_data.to_json))
    
        expect(service.send(:fetch_geo_location_data)).to eq(converted_geo_location_data)
      end
    end

    context '#fetch_weather_details' do
      it 'returns weather details' do
        url = "http://api.openweathermap.org/data/2.5/weather?lat=#{geo_location_data['lat']}&lon=#{geo_location_data['lon']}&appid=test-api-key&units=metric"
        allow(service).to receive(:open).with(url).and_return(StringIO.new(weather_data.to_json))

        expect(service.send(:fetch_weather_details, geo_location_data['lat'], geo_location_data['lon'])).to eq(weather_data)
      end
    end

    context '#cache_weather_data' do
      it 'caches weather data' do
        expect(Rails.cache).to receive(:write).with("weather_data_#{address}", weather_data.to_json, expires_in: 30.minutes)

        service.send(:cache_weather_data, weather_data)
      end
    end
  end
end