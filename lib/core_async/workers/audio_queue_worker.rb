module CoreAsync

  class AudioQueueWorker
    
    include Sidekiq::Worker
    sidekiq_options :queue => :audio_queue, :retry => 0, :dead => true

    defined?(AudioQueueWorkerMethods) and include AudioQueueWorkerMethods

  end

end