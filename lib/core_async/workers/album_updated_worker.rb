module CoreAsync

  class AlbumUpdatedWorker
    
    include Sidekiq::Worker
    sidekiq_options :queue => :album_updated, :retry => 0, :dead => true

    defined?(CoreAsync::AlbumUpdatedWorkerMethods) and include CoreAsync::AlbumUpdatedWorkerMethods

  end

end