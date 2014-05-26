
ENV['RACK_ENV']||='production'

app_root = File.expand_path('../..',__FILE__)

require 'clockwork'

require "#{app_root}/config/application.rb"


module Clockwork

  every(1.week, :gen_hnsjt, :at=> 'Sunday 23:56')

  


  handler do |job, time|
    dispatch(job,time)
  end

  class << self

    def dispatch(job,time=nil)
      logger.info("#{Time.now} before starting job : #{job}")
      CoreAsync::SubappScheduleWorker.perform_async(job)
      logger.info("#{Time.now} after staring job : #{job}")
    end

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/clock_work/subapp#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end
  end

end