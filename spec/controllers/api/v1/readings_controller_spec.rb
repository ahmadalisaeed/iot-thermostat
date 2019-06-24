# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ReadingsController do
  let(:thermostat) { create(:thermostat, location: 'Berlin') }
  let(:reading) { create(:reading, thermostat_id: thermostat.id, number: thermostat.next_sequence_number) }

  describe '#create' do
    let(:temperature) { 30.7 }
    let(:humidity) { 0.67 }
    let(:battery_charge) { 0.8 }

    subject do
      post :create, params: { reading: { temperature: temperature,
                                         humidity: humidity,
                                         battery_charge: battery_charge } }
    end

    context 'when no houshold token provided' do
      it 'should return error' do
        subject
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)).to eq('error' => 'Unknown household')
      end
    end

    context 'when houshold token provided' do
      before(:each) do
        request.headers['Authorization'] = thermostat.household_token
      end

      it 'returns a sequence number' do
        subject
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).not_to eq(number: nil)
        expect(JSON.parse(response.body)).to eq('number' => thermostat.next_sequence_number - 1)
      end

      it 'should persist the reading' do
        subject
        response_body = JSON.parse(response.body)

        reading_id = response_body['number']
        reading = thermostat.find_reading reading_id

        expect(reading_id).not_to eq(nil)
        expect(reading.number).to eq(reading_id)
        expect(reading.temperature).to eq(temperature)
        expect(reading.humidity).to eq(humidity)
        expect(reading.battery_charge).to eq(battery_charge)
      end
    end
  end

  describe '#show' do
    let(:expected_show) do
      {
        'number' => reading.number,
        'temperature' => reading.temperature,
        'humidity' => reading.humidity,
        'battery_charge' => reading.battery_charge
      }
    end .to_json

    subject { get :show, params: { id: reading.number } }

    context 'when no houshold token provided' do
      it 'should return error' do
        subject
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)).to eq('error' => 'Unknown household')
      end
    end

    context 'when houshold token provided' do
      it 'should return the reading' do
        request.headers['Authorization'] = thermostat.household_token
        subject
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(expected_show)
      end
    end
  end
end
