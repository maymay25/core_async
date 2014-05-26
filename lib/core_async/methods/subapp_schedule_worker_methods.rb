module CoreAsync

  module SubappScheduleWorkerMethods

    def perform(action,*args)
      method(action).call(*args)
    end

    


    private

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/sidekiq/track_off#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end
  end


end