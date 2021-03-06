module CoreAsync

  class TrackPlayedWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :track_played, :retry => 0, :dead => true

    defined?(CoreAsync::TrackPlayedWorkerMethods) and include CoreAsync::TrackPlayedWorkerMethods

  end

end