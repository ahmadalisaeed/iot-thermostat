# frozen_string_literal: true

class Reading < ApplicationRecord
  belongs_to :thermostat

  def self.statistics
    select(" COUNT(*) as total_count,
             AVG(temperature) as avg_temperature,
             MIN(temperature) as min_temperature,
             MAX(temperature) as max_temperature,
             AVG(humidity) as avg_humidity,
             MIN(humidity) as min_humidity,
             MAX(humidity) as max_humidity,
             AVG(battery_charge) as avg_battery_charge,
             MIN(battery_charge) as min_battery_charge,
             MAX(battery_charge) as max_battery_charge").map do |s|
      {
        temperature: {
          minimum: s.min_temperature,
          maximum: s.max_temperature,
          average: s.avg_temperature
        },
        humidity: {
          minimum: s.min_humidity,
          maximum: s.max_humidity,
          average: s.avg_humidity
        },
        battery_charge: {
          minimum: s.min_battery_charge,
          maximum: s.max_battery_charge,
          average: s.avg_battery_charge
        },
        count: s.total_count
      }
    end .first
  end
end
