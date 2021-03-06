module CoreAsync

  class MessagesSendWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :messages_send, :retry => 0, :dead => true

    defined?(CoreAsync::MessagesSendWorkerMethods) and include CoreAsync::MessagesSendWorkerMethods

  end

end