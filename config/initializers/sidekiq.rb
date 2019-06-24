# frozen_string_literal: true

settings = {
  url: ENV['REDIS_URL']
}

Sidekiq.configure_server do |config|
  config.redis = settings
end

Sidekiq.configure_client do |config|
  config.redis = settings
end
