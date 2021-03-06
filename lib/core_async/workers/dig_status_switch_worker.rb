module CoreAsync

  class DigStatusSwitchWorker
    
    include Sidekiq::Worker
    sidekiq_options :queue => :dig_status_switch, :retry => 0, :dead => true

    defined?(CoreAsync::DigStatusSwitchWorkerMethods) and include CoreAsync::DigStatusSwitchWorkerMethods

  end

end