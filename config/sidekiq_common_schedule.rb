
ENV['RACK_ENV']||='production'

app_root = File.expand_path('../..',__FILE__)

require 'clockwork'

require "#{app_root}/config/application.rb"


module Clockwork

  every(1.day, :backup_human_recommends, :at=> '23:55')

  every(1.day, :update_baidu_count, :at=> '00:00')

  every(1.day, :update_channel_stat, :at=> '07:10')

  every(1.day, :check_special_human_recommends, :at=> '23:54')

  every(1.day, :gen_andchannel_focus, :at=> '**:55', :if => lambda { |t| (6..23).include?(t.hour)} )

  every(1.day, :login_day, :at=> '08:01')
  
  handler do |job, time|
    dispatch(job,time)
  end

  class << self

    def dispatch(job,time=nil)
      logger.info("#{Time.now} before starting job : #{job}")
      CoreAsync::CommonScheduleWorker.perform_async(job)
      logger.info("#{Time.now} after starting job : #{job}")
    end

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/clock_work/common#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end
  end

end