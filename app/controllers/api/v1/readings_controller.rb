# frozen_string_literal: true

module Api
  module V1
    class ReadingsController < BaseController
      def create
        reading_hash = current_thermostat.cache_reading(reading_params.to_hash)
        CreateReadingWorker.perform_async(current_thermostat.id, reading_hash[:number])
        render json: { number: reading_hash[:number] }
      end

      def show
        @reading = current_thermostat.find_reading params[:id]
        render json: @reading
      end

      private

      def reading_params
        params.require(:reading).permit(:temperature, :humidity, :battery_charge).merge(thermostat_id: current_thermostat.id)
      end
    end
  end
end
