module CoreAsync

  class SubappScheduleWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :subapp_schedule, :retry => 0, :dead => true

    defined?(CoreAsync::SubappScheduleWorkerMethods) and include CoreAsync::SubappScheduleWorkerMethods

  end

end