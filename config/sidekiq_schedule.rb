
ENV['RACK_ENV']||='production'

app_root = File.expand_path('../..',__FILE__)

require 'clockwork'

require "#{app_root}/config/application.rb"



module Clockwork

  handler do |job, time|
    dispatch(job,time)
  end

  every(2.seconds, :test_function)

  every(10.seconds, :frequent_job)
  every(3.minutes, :less_frequent_job)
  every(1.hour, :hourly_job)

  every(1.day, :midnight_job, :at=> '17:58')


  class << self

    def dispatch(job,time=nil)
      logger.info("#{Time.now} before do : #{job}")
      CoreAsync::ScheduleWorker.perform_async(job,'i am jeffrey')
      logger.info("#{Time.now} after do : #{job}")
    end

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/clock_work/#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end
  end

end