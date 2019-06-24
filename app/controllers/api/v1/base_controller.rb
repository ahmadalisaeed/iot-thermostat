# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::Helpers

      helper_method :current_thermostat

      before_action :authenticate_thermostat

      def authenticate_thermostat
        render json: { error: 'Unknown household' }, status: 401 if current_thermostat.blank?
      end

      def current_thermostat
        @thermostat ||= Thermostat.find_by_household_token household_token
      end

      def household_token
        header = request.headers['Authorization']
        header = header.split(' ').last if header
        header
      end
    end
  end
end
