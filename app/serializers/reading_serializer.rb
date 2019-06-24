# frozen_string_literal: true

class ReadingSerializer < ActiveModel::Serializer
  attributes :number, :temperature, :humidity, :battery_charge
end
