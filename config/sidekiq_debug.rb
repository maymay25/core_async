

require File.expand_path("../core_async_client.rb",__FILE__)


### subapp_schedule

#CoreAsync::SubappScheduleWorker.perform_async(:subapp_track_day_download)


### common_schedule

CoreAsync::CommonScheduleWorker.perform_async(:check_special_human_recommends)
CoreAsync::CommonScheduleWorker.perform_async(:backup_human_recommends)
CoreAsync::CommonScheduleWorker.perform_async(:update_baidu_count)
CoreAsync::CommonScheduleWorker.perform_async(:update_channel_stat)
CoreAsync::CommonScheduleWorker.perform_async(:gen_andchannel_focus)
CoreAsync::CommonScheduleWorker.perform_async(:login_day_download)
CoreAsync::CommonScheduleWorker.perform_async(:track_day_download)
CoreAsync::CommonScheduleWorker.perform_async(:user_day_download)

