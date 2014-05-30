# coding: utf-8

require File.expand_path('../lib/core_async/version.rb',__FILE__)

Gem::Specification.new do |spec|
  spec.name          = "core_async"
  spec.version       = CoreAsync::Version
  spec.authors       = ["Jeffrey"]
  spec.email         = ["jeffrey6052@163.com"]
  spec.description   = ""
  spec.summary       = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = [
    'lib/core_async/methods/album_off_worker_methods.rb',
    'lib/core_async/methods/album_resend_worker_methods.rb',
    'lib/core_async/methods/album_updated_worker_methods.rb',
    'lib/core_async/methods/backend_worker_methods.rb',
    'lib/core_async/methods/comment_created_worker_methods.rb',
    'lib/core_async/methods/comment_destroyed_worker_methods.rb',
    'lib/core_async/methods/dig_status_switch_worker_methods.rb',
    'lib/core_async/methods/favorite_created_worker_methods.rb',
    'lib/core_async/methods/following_created_worker_methods.rb',
    'lib/core_async/methods/following_destroyed_worker_methods.rb',
    'lib/core_async/methods/message_created_worker_methods.rb',
    'lib/core_async/methods/messages_send_worker_methods.rb',
    'lib/core_async/methods/relay_created_worker_methods.rb',
    'lib/core_async/methods/track_off_worker_methods.rb',
    'lib/core_async/methods/track_on_worker_methods.rb',
    'lib/core_async/methods/track_played_worker_methods.rb',
    'lib/core_async/methods/user_off_worker_methods.rb',
    'lib/core_async/methods/user_on_worker_methods.rb',
    'lib/core_async/methods/common_schedule_worker_methods.rb',
    'lib/core_async/methods/news_rss_schedule_worker_methods.rb',
    'lib/core_async/methods/subapp_schedule_worker_methods.rb',
    'lib/core_async/methods/subapp_worker_methods.rb',
    'lib/core_async/methods/audio_queue_worker_methods.rb',
    'lib/core_async/workers/album_off_worker.rb',
    'lib/core_async/workers/album_resend_worker.rb',
    'lib/core_async/workers/album_updated_worker.rb',
    'lib/core_async/workers/backend_worker.rb',
    'lib/core_async/workers/comment_created_worker.rb',
    'lib/core_async/workers/comment_destroyed_worker.rb',
    'lib/core_async/workers/dig_status_switch_worker.rb',
    'lib/core_async/workers/favorite_created_worker.rb',
    'lib/core_async/workers/following_created_worker.rb',
    'lib/core_async/workers/following_destroyed_worker.rb',
    'lib/core_async/workers/message_created_worker.rb',
    'lib/core_async/workers/messages_send_worker.rb',
    'lib/core_async/workers/relay_created_worker.rb',
    'lib/core_async/workers/track_off_worker.rb',
    'lib/core_async/workers/track_on_worker.rb',
    'lib/core_async/workers/track_played_worker.rb',
    'lib/core_async/workers/user_off_worker.rb',
    'lib/core_async/workers/user_on_worker.rb',
    'lib/core_async/workers/common_schedule_worker.rb',
    'lib/core_async/workers/news_rss_schedule_worker.rb',
    'lib/core_async/workers/subapp_schedule_worker.rb',
    'lib/core_async/workers/subapp_worker.rb',
    'lib/core_async/workers/audio_queue_worker.rb',
    'lib/core_async/methods.rb',
    'lib/core_async/workers.rb',
    'lib/core_async/server.rb',
    'lib/core_async/version.rb',
    'lib/core_async.rb',
    'core_async.gemspec']

  spec.add_dependency 'sidekiq', '~> 3.0'
end
