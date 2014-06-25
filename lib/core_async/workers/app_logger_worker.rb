module CoreAsync

  class AppLoggerWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :app_logger, :retry => 0, :dead => true

    defined?(CoreAsync::AppLoggerWorkerMethods) and include CoreAsync::AppLoggerWorkerMethods

  end

end