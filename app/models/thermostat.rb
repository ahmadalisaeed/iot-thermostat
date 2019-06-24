# frozen_string_literal: true

class Thermostat < ApplicationRecord
  include ReadingCacheable

  has_secure_token :household_token

  has_many :readings

  def find_reading(number)
    reading = find_cached_reading(number)
    reading ||= readings.find_by_number(number)
    reading
  end

  def readings_statistics
    readings_stats = readings.statistics
    cached_readings_stats = cached_readings_statistics
    saved_reading_count   = readings_stats[:count]
    cached_readings_count = cached_readings_stats[:count]

    total_count =  saved_reading_count + cached_readings_count

    %i[temperature humidity battery_charge].each do |key|
      readings_stat = readings_stats[key] || {}
      cached_readings_stat = cached_readings_stats[key] || {}

      sum = 0
      sum = readings_stat[:average] * saved_reading_count if saved_reading_count > 0
      sum += cached_readings_stat[:average] * cached_readings_count if cached_readings_count > 0

      average = (sum / total_count).round(2)

      readings_stats[key] = {
        minimum: [readings_stat[:minimum], cached_readings_stat[:minimum]].compact.min,
        maximum: [readings_stat[:maximum], cached_readings_stat[:maximum]].compact.max,
        average: average
      }
    end

    readings_stats[:count] = total_count

    readings_stats
  end
end
