require 'hbaserb'

module CoreAsync

  module ScheduleWorkerMethods

    def perform(action,*args)
      method(action).call(*args)
    end

    def test_function(msg)

      logger.info(msg)

    rescue Exception => e
      logger.error "#{Time.now} #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end


    private



    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/sidekiq/schedule#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end

  end

end