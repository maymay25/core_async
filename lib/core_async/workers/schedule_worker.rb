module CoreAsync

  class ScheduleWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :schedule, :retry => 0, :dead => true

    defined?(ScheduleWorkerMethods) and include ScheduleWorkerMethods

  end

end