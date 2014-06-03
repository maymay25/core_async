#!/usr/bin/env ruby
# 打包ios版子APP 229打包服务器网络连接模式是nat，amqp监听web1会死连，所以写了这个bunny版

ENV['RACK_ENV']||='production'
app_root = File.expand_path('../..',__FILE__)
require "#{app_root}/config/core_async_server.rb"

require 'amqp'

@queue_name = Settings.queue.packapp.ios
@buildpy = Settings.buildiospy
@buildsh = Settings.buildiossh

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

  puts payload.inspect
  
  now = Time.new
  logger = Logger.new(File.join(Settings.log_path, "#{@queue_name}.log"))
  begin
    params = Oj.load(payload)
    # { sub_app_log_id: sub_app_log_id, app_id: app_id, version: version, version_code: version_code, 
    #   app_name: app_name, app_certificate_name: app_certificate_name, app_envir: app_envir }
    
    logger.info("#{now} build.py")
    logger.info params
    if system("#{@buildpy} #{params['app_id']} #{params['version']}")
      logger.info("#{now} build.sh")
      res = system("#{@buildsh} '#{params['app_name']}' '#{params['app_certificate_name'].strip}' #{params['version']} #{params['app_envir']} #{params['profile']} #{params['is_file']} #{params['time']} #{params['security_key']}")

      if res
        status = 2
      else
        status = 3
        backtrace = 'build.sh failed'
      end
    else
      status = 3
      backtrace = 'buildios.py failed'
    end
    logger.info("#{Time.new - now}s")

    begin
      $rabbitmq_channel.queue('packapp.feedback', durable: true).publish(oj_dump({sub_app_log_id: params['sub_app_log_id'], status: status, backtrace: backtrace}), content_type: 'text/plain')
      logger.info("published")
    rescue Errno::ECONNRESET => e
      @error_logger.error "#{Time.new} #{e.class}, retry publish packapp.feedback"
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
