# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::StatsController do
  let(:thermostat) { create(:thermostat, location: 'Berlin') }
  let(:reading1) { create(:reading, thermostat_id: thermostat.id, number: thermostat.next_sequence_number) }
  let(:reading2) { create(:reading, thermostat_id: thermostat.id, number: thermostat.next_sequence_number) }
  let(:reading3) { create(:reading, thermostat_id: thermostat.id, number: thermostat.next_sequence_number) }

  describe '#index' do
    subject { get :index }

    context 'when no houshold token provided' do
      it 'should return error' do
        subject
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)).to eq('error' => 'Unknown household')
      end
    end

    context 'when houshold token provided' do
      let(:cached_reading1) do
        {  temperature: Faker::Number.decimal(2),
           humidity: Faker::Number.decimal(2),
           battery_charge: Faker::Number.decimal(2) }
      end

      let(:cached_reading2) do
        {  temperature: Faker::Number.decimal(2),
           humidity: Faker::Number.decimal(2),
           battery_charge: Faker::Number.decimal(2) }
      end

      let(:expected_show) do
        {
          'temperature' => {
            'average' => (thermostat.all_readings.pluck(:temperature).reduce(:+) / thermostat.all_readings.count).round(2),
            'minimum' => thermostat.all_readings.pluck(:temperature).min,
            'maximum' => thermostat.all_readings.pluck(:temperature).max
          },
          'humidity' => {
            'average' => (thermostat.all_readings.pluck(:humidity).reduce(:+) / thermostat.all_readings.count).round(2),
            'minimum' => thermostat.all_readings.pluck(:humidity).min,
            'maximum' => thermostat.all_readings.pluck(:humidity).max
          },
          'battery_charge' => {
            'average' => (thermostat.all_readings.pluck(:battery_charge).reduce(:+) / thermostat.all_readings.count).round(2),
            'minimum' => thermostat.all_readings.pluck(:battery_charge).min,
            'maximum' => thermostat.all_readings.pluck(:battery_charge).max
          },
          'count' => thermostat.all_readings.count
        }
      end .to_json

      it 'returns statistics for saved readings' do
        reading3
        reading1
        reading2

        request.headers['Authorization'] = thermostat.household_token
        subject
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(expected_show)
      end

      it 'returns statistics for cached readings' do
        thermostat.cache_reading(cached_reading1)
        thermostat.cache_reading(cached_reading2)

        request.headers['Authorization'] = thermostat.household_token
        subject
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(expected_show)
      end

      it 'returns statistics for all readings' do
        reading3
        reading1
        reading2

        thermostat.cache_reading(cached_reading1)
        thermostat.cache_reading(cached_reading2)

        request.headers['Authorization'] = thermostat.household_token
        subject
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(expected_show)
      end
    end
  end
end
