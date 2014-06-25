module CoreAsync

  class CommonScheduleWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :common_schedule, :retry => 0, :dead => true

    defined?(CommonScheduleWorkerMethods) and include CommonScheduleWorkerMethods

  end

end