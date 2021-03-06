# frozen_string_literal: true

class CreateThermostats < ActiveRecord::Migration[5.2]
  def change
    create_table :thermostats do |t|
      t.text :household_token
      t.text :location

      t.timestamps
    end
  end
end
