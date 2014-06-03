#!/usr/bin/env ruby
# 打包ios版子APP 229打包服务器网络连接模式是nat，amqp监听web1会死连，所以写了这个bunny版

ENV['RACK_ENV']||='production'
app_root = File.expand_path('../..',__FILE__)
require "#{app_root}/config/core_async_server.rb"

require 'amqp'

@queue_name = Settings.queue.packapp.android
@buildpy = Settings.buildandpy

@error_logger = Logger.new(File.join(Settings.log_path, "#{@queue_name}.error.log"))

def oj_dump(json)
  Oj.dump(json, mode: :compat)
end

def seek_queue
  delivery_info, metadata, payload = $rabbitmq_channel.queue(@queue_name).pop

  unless payload
    sleep 5
    return
  end

  now = Time.new
  # puts now
  logger = Logger.new(File.join(Settings.log_path, "#{@queue_name}.log"))
  # logger.info(payload.inspect)
  begin
    params = Oj.load(payload)
    # puts params['key'].nil?
    # return params['key'].nil? 

    logger.info("#{now} build.py")
    
    cmd = "#{@buildpy} #{params['app_id']} #{params['version']} #{params['version_code']} #{params['key'].nil? ? '2NP0xGDixNsGifuPp6hADI4T' : params['key']} #{params['security_key']}"
    logger.info(cmd)
    res = system(cmd)
    logger.info("#{Time.new - now}s")

    if res
      status = 2
    else
      status = 3
      backtrace = 'buildand.py failed'
    end

    begin
      $rabbitmq_channel.queue('packapp.feedback', durable: true).publish(oj_dump({sub_app_log_id: params['sub_app_log_id'], status: status, backtrace: backtrace}), content_type: 'text/plain')
    rescue Errno::ECONNRESET => e
      @error_logger.error "#{Time.new} #{e.class}, retry"
      $rabbitmq_connection.stop
      $rabbitmq_connection.start
      retry
    end
  rescue Exception => e
    @error_logger.error("#{now} #{e.class}: #{e.message}\n #{e.backtrace.join("\n")}")
  end

end

loop do

  begin 
    seek_queue
  rescue Bunny::ServerDownError => e
    @error_logger.error "#{Time.new} #{e.class}, retry"
    sleep 10
    retry
  rescue Errno::ECONNRESET => e
    @error_logger.error "#{Time.new} #{e.class}, retry"
    sleep 10
    retry
  rescue Timeout::Error => e
    @error_logger.error "#{Time.new} #{e.class}, retry"
    sleep 10
    retry
  rescue Exception => e
    @error_logger.error "#{Time.new} #{e.class}, #{e.backtrace.join("\n")}, raise"
    raise e
  end
  
end
