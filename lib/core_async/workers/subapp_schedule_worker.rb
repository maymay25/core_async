module CoreAsync

  class SubappScheduleWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :subapp_schedule, :retry => 0, :dead => true

    defined?(SubappScheduleWorkerMethods) and include SubappScheduleWorkerMethods

  end

end