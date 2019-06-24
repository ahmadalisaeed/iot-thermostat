# frozen_string_literal: true

module ReadingCacheable
  def next_sequence_number

    current_value = ReadCache.redis.get(sequence_key)
    if current_value.nil?
      current_value = readings.pluck(:number).max.to_i 
      ReadCache.redis.set(sequence_key, current_value)
    end

    result = ReadCache.redis.multi do |multi|
      multi.incr(sequence_key)
    end
    result.last

  end

  def all_readings
    readings + cached_readings.map { |r| Reading.new(r) }
  end

  def cached_readings_statistics
    cached_readings_array = cached_readings
    return { count: 0 } if cached_readings_array.empty?

    stats = {}
    %i[temperature humidity battery_charge].each do |key|
      values = cached_readings_array.map { |r| r[key.to_s].to_f }
      min = values.min
      max = values.max
      avg = values.reduce(:+) / values.count
      stats[key] = { minimum: min, maximum: max, average: avg }
    end
    stats[:count] = cached_readings_array.length
    stats
  end

  def find_cached_reading(number)
    return nil if cached_readings.empty?

    reading = cached_readings.select { |r| r['number'] == number }.first
    reading = Reading.new(reading) unless reading.nil?
    reading
  end

  def cache_reading(reading_hash)
    redis_lock = Redis::Lock.new(ReadCache.redis, lock_key)
    redis_lock.lock

    reading_hash[:number] = next_sequence_number
    cached_readings_array = cached_readings
    cached_readings_array.push reading_hash

    ReadCache.redis.set(readings_key, cached_readings_array.to_json)

    redis_lock.unlock

    reading_hash
  end

  def remove_cached_reading(number)
    redis_lock = Redis::Lock.new(ReadCache.redis, lock_key)

    redis_lock.lock

    cached_readings_array = cached_readings.reject { |r| r['number'] == number }
    ReadCache.redis.set(readings_key, cached_readings_array.to_json)

    redis_lock.unlock
  end

  def cached_readings
    cached_readings = ReadCache.redis.get(readings_key)
    cached_readings = '[]' if cached_readings.nil?
    JSON.parse(cached_readings)
  end

  def sequence_key
    "#{self.class.name}_#{id}_sequence"
  end

  def readings_key
    "#{self.class.name}_#{id}_readings"
  end

  def lock_key
    "#{self.class.name}_#{id}_lock"
  end
end
