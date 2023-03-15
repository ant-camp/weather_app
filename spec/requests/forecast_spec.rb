# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Forecasts', type: :request do
    describe 'GET /forecast' do
      let(:weather_data) do
        {
          'main' => {
            'temp' => 25.0,
            'temp_min' => 22.0,
            'temp_max' => 28.0
          }
        }
      end
  
      context 'when the address is provided' do
        let(:address) { 'Tampa, FL' }
  
        before do
          allow_any_instance_of(ForecastService).to receive(:get_weather_data).and_return(weather_data)
          get '/forecast', params: { address: address }
        end
  
        it 'returns a successful response' do
          expect(response).to have_http_status(:success)
        end
  
        it 'renders the correct weather data' do
          expect(response.body).to include('Current Temperature: 25.0')
          expect(response.body).to include('High Temperature: 28.0')
          expect(response.body).to include('Low Temperature: 22.0')
        end
      end
  
      context 'when the address is not provided' do
        before do
          allow_any_instance_of(ForecastService).to receive(:get_weather_data).and_return(weather_data)
          get '/forecast'
        end
  
        it 'returns a successful response' do
          expect(response).to have_http_status(:success)
        end
  
        it 'renders the correct weather data' do
          expect(response.body).to include('Current Temperature: 25.0')
          expect(response.body).to include('High Temperature: 28.0')
          expect(response.body).to include('Low Temperature: 22.0')
        end
      end
  
      context 'when the service returns no data' do
        before do
          allow_any_instance_of(ForecastService).to receive(:get_weather_data).and_return(nil)
          get '/forecast'
        end
  
        it 'returns a successful response' do
          expect(response).to have_http_status(:success)
        end
  
        it 'displays an error message' do
          expect(response.body).to include('Unable to fetch weather data for the given address.')
        end
      end
    end
  end