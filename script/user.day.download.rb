
require File.expand_path("../core_async_client.rb",__FILE__)

CoreAsync::CommonScheduleWorker.perform_async(:user_day_download)