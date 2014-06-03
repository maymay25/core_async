
require File.expand_path("../core_async_client.rb",__FILE__)

CoreAsync::NewsRssScheduleWorker.perform_async(:gen_hnxxt_rss)