require 'bunny'

def new_bunny!
  $rabbitmq_connection = Bunny.new(Settings.amqp_web)
  $rabbitmq_connection.start
end

new_bunny!
