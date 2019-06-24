# frozen_string_literal: true

class CreateReadingWorker
  include Sidekiq::Worker

  sidekiq_options queue: :priority

  def perform(thermostat_id, reading_number)
    thermostat = Thermostat.find thermostat_id
    reading = thermostat.find_cached_reading reading_number
    if reading.present?
      reading.save
      thermostat.remove_cached_reading reading_number
    end
  end
end
