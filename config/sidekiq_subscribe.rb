

require File.expand_path("../subscribe_lib.rb",__FILE__)

require 'amqp'
require 'eventmachine'

EventMachine.run do
  AMQP.start(host: Settings.rabbitmq.host) do |connection|
    channel = AMQP::Channel.new(connection)

    subscribe_track_played(channel)

    subscribe_following_created(channel)

    subscribe_album_off(channel)

    subscribe_track_off(channel)
  end
end








