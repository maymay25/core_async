
require File.expand_path("../core_async_client.rb",__FILE__)

CoreAsync::SubappScheduleWorker.perform_async(:subapp_track_day_download)