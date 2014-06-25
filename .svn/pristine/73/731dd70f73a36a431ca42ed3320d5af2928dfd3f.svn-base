
require 'clockwork'

require File.expand_path("../core_async_client.rb",__FILE__)

puts 'deploying sidekiq_schedule ...'

module Clockwork

  handler do |job, time|
    dispatch(job,time)
  end


  #TO BE FIXED

  # every(5.seconds, :update_channel_stat)  # scaner id is invalid

  # every(5.seconds, :login_day_download)  # scaner id is invalid

  # every(5.seconds, :subapp_track_day_download)  # scaner id is invalid

  #common
  every(1.day, :backup_human_recommends, :at=> '23:55')

  every(1.day, :update_baidu_count, :at=> '00:00')

  every(1.day, :update_channel_stat, :at=> '07:10')

  every(1.day, :check_special_human_recommends, :at=> '23:54')

  every(1.day, :delayed_publish, :at=> '00:00')

  every(1.day, :gen_andchannel_focus, :at=> '**:55', :if => lambda { |t| (6..23).include?(t.hour)} )

  every(1.day, :login_day_download, :at=> '08:01')

  every(1.day, :user_day_download, :at=> '08:31')

  every(1.day, :track_day_download, :at=> '08:35')

  #news_rss
  every(1.week, :gen_hnsjt_rss, :at=> 'Sunday 23:56')

  every(1.day, :gen_hnxxt_rss, :at=> '**:57', :if => lambda { |t| (6..23).include?(t.hour)} )

  every(1.day, :gen_sohunews_rss, :at=> '**:58', :if => lambda { |t| (6..23).include?(t.hour)} )

  every(1.day, :gen_neteasenews_rss, :at=> '**:59', :if => lambda { |t| (6..23).include?(t.hour)} )
  

  #subapp
  every(1.day, :subapp_track_day_download, :at=> '08:30')


  class << self

    def dispatch(job,time=nil)
      logger.info("starting : #{job} ...")
      case job
      when :subapp_track_day_download
        CoreAsync::SubappScheduleWorker.perform_async(job)
      when :gen_hnsjt_rss, :gen_hnxxt_rss, :gen_sohunews_rss, :gen_neteasenews_rss
        CoreAsync::NewsRssScheduleWorker.perform_async(job)
      else
        CoreAsync::CommonScheduleWorker.perform_async(job)
      end

      logger.info("starting : #{job} ... OK")
    end

    @@app_root = File.expand_path('../..',__FILE__)

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day

        @@logger = ::Logger.new(@@app_root+"/log/schedule/#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end
  end

end

puts 'deploying sidekiq_schedule ... DONE'