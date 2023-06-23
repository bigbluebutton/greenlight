# frozen_string_literal: true

require 'action_cable/subscription_adapter/redis'

ActionCable::SubscriptionAdapter::Redis.redis_connector = lambda { |config|
  config[:id] = nil
  Redis.new(config.except(:adapter, :channel_prefix))
}
