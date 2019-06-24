# frozen_string_literal: true

# redis = Redis.new(url: ENV['REDIS_URL'])

# To clear out the db before each test

module ReadCache
  class << self
    def redis
      @redis ||= Redis.new(url: (ENV['REDIS_URL'] || 'redis://127.0.0.1:6379'))
      # @redis.flushdb if Rails.env == "test"
      # @redis
    end
  end
end
