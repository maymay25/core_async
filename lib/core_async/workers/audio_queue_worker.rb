module CoreAsync

  class AudioQueueWorker
    
    include Sidekiq::Worker
    sidekiq_options :queue => :audio_queue, :retry => 0, :dead => true

    defined?(CoreAsync::AudioQueueWorkerMethods) and include CoreAsync::AudioQueueWorkerMethods

  end

end