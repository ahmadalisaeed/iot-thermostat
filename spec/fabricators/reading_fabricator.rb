# frozen_string_literal: true

Fabricator(:reading) do
  temperature { Faker::Number.decimal 2 }
  humidity { Faker::Number.decimal 2 }
  battery_charge { Faker::Number.decimal 2 }
end
