# frozen_string_literal: true

module Api
  module V1
    class StatsController < BaseController
      def index
        render json: current_thermostat.readings_statistics
      end
    end
  end
end
