
puts 'deploying sidekiq_subscribe ...'

require 'amqp'
require 'eventmachine'

require File.expand_path("../core_async_client.rb",__FILE__)

require File.expand_path("../subscribe_lib.rb",__FILE__)


EventMachine.run do
  AMQP.start(host: Settings.rabbitmq.host) do |connection|
    channel = AMQP::Channel.new(connection)

    subscribe_track_played(channel)

    subscribe_incr_album_plays_track_played(channel)

    subscribe_following_created(channel)

    subscribe_album_updated_dj(channel)

    subscribe_album_off(channel)

    subscribe_track_on(channel)

    subscribe_track_off(channel)

    subscribe_album_resend(channel)

    subscribe_comment_created_dj(channel)

    subscribe_comment_destroyed_rb(channel)

    subscribe_favorite_created_dj(channel)

    subscribe_following_created_rb(channel)

    subscribe_following_destroyed_rb(channel)

    subscribe_message_created_dj(channel)

    subscribe_relay_created_rb(channel)

    subscribe_audio_queue(channel)

    subscribe_dig_status_to(channel)

    subscribe_update_track_pic_category(channel)

    subscribe_user_audit(channel)

    subscribe_announcements(channel)

    subscribe_user_update_audit(channel)

    subscribe_messages_dj(channel)

    subscribe_last_uptrack(channel)

    subscribe_subapp_created(channel)

    subscribe_packapp_feedback(channel)

  end
end

puts 'deploying sidekiq_subscribe ... DONE'








