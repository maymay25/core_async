module CoreAsync

  class NewsRssScheduleWorker

    include Sidekiq::Worker
    sidekiq_options :queue => :news_rss_schedule, :retry => 0, :dead => true

    defined?(NewsRssScheduleWorkerMethods) and include NewsRssScheduleWorkerMethods

  end

end