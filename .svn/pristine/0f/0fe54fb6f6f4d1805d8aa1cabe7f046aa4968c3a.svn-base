# -*- encoding: utf-8 -*-
begin

ENV['RACK_ENV']||='production'

app_root = File.expand_path('../..',__FILE__)

require "#{app_root}/config/core_async_server.rb"

require 'core_async_hbaserb'
require 'writeexcel'

logger = Logger.new("#{app_root}/log/script/track.listen.log")

logger.info Time.now
logger.info "start"

#查询方法
def search_list(day)   
  table_name = "hb_play_track_day"
  start_time = day.gsub('-','')
  end_time = (day.to_date + 1.day).to_s.gsub('-','')    

  client = HbaseClient.new(Settings.hbase_ip, 9090)
  client.start
  return client.scanner_track(table_name,start_time,end_time)  
  client.close
end

#秒转换为时分秒格式
def time_format(time)
  clean_time = time

  hour = (clean_time / 3600).to_i
  min = ((clean_time - hour * 3600) / 60).to_i
  sec = (clean_time - hour * 3600 - min * 60).to_i

  return "#{hour}:#{min}:#{sec}"
end

#字符串转换成时分秒格式
def time_format2(time)
  return 0 if time.class == Array
  return 'error' if time.empty? || time == 'error'
  time_str = time.gsub(/[T+:]/, '-')
  time_arr = time_str.split("-")
  Time.new(time_arr[0].to_i,
          time_arr[1].to_i,
          time_arr[2].to_i,
          time_arr[3].to_i,
          time_arr[4].to_i,
          time_arr[5].to_i
          ).strftime("%Y-%m-%d %H:%M:%S") 
end

  # puts "start"
# (0..3).each do |n|
# puts n

  # time = Time.new(2013,9,24).to_date

  time = Time.now.to_date - 1.day
  logger.info "time init"
  logger.info time.to_s
  data = search_list(time.to_s)
  # time = time + n.day
  logger.info "data init"
  logger.info data.class
  # logger.info data

  array_1 = []
  array_3 = []
   
  data.each do |v|
    array_1 << v.values
  end

  logger.info "data transf array"

  array_1.each do |a|
    # unless a[29] == 'error'
    #   profile = Profile.where(uid: a[29]).select('nickname').first
    # end
    unless a[22] == 'error'
      category = Category.where(id: a[22]).select('title').first
    end
    unless a[28] == 'error'
      track = Track.stn(a[28]).where(id: a[28].to_i).first
    end
    
    array_2 = []
    array_2[0] = track ? "'#{track.title}" : "error"  #声音名称
    array_2[1] = category ? category.title : "error" #分类名称
    array_2[2] = a[26][0] == -1 ? "是" : "否"  #是否爬虫
    array_2[3] = 0 #发布用户
    array_2[4] = time_format2(a[23]) #发布时间
    array_2[5] = a[27][0] #收听总人数
    array_2[6] = a[5][0] #web端收听人数
    array_2[7] = a[2][0] #mb端收听人数
    array_2[8] = a[11][0] #iphone端收听人数
    array_2[9] = a[14][0] #iphad端收听人数
    array_2[10] = a[17][0] #chezai端收听人数
    array_2[11] = a[20][0] #android端收听人数
    array_2[12] = a[8][0] #wp端收听人数
    array_2[13] = a[25][0] #收听总次数
    array_2[14] = a[4][0] #web端收听次数
    array_2[15] = a[1][0] #mb端收听次数
    array_2[16] = a[10][0] #iphone端收听次数
    array_2[17] = a[13][0] #ipad端收听次数
    array_2[18] = a[16][0] #chezai端收听次数
    array_2[19] = a[19][0] #android端收听次数
    array_2[20] = a[7][0] #wp端收听次数
    array_2[21] = a[24][0] #收听总时长 
    array_2[22] = a[0][0] #mb端收听时长 
    array_2[23] = a[3][0] #web端收听时长
    array_2[24] = a[9][0] #iphone端收听时长 
    array_2[25] = a[12][0] #ipad端收听时长
    array_2[26] = a[15][0] #chezai端收听时长 
    array_2[27] = a[18][0] #android端收听时长 
    array_2[28] = a[6][0] #wp端收听时长
    array_2[29] = a[28] #声音id
    array_2[30] = a[29] #用户id

    array_3 << array_2      
  end 

  logger.info "data complete"
  
  #根目录是否存在，不存在则新建
  unless Dir.exist?(Settings.stat_root)
    FileUtils.mkdir_p(Settings.stat_root)
  end
  
  #目录不存在时新建
  unless Dir.exist?("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
    FileUtils.mkdir_p("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
  end

  logger.info "mkdir"

  # data = array_3
  len = array_3.size
  
  workbook = WriteExcel.new("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}/#{time}_track.xls")
     
  logger.info "excel init"
  logger.info "#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}/#{time}_track.xls" 
  
  #一页最多65536行,大于的新建工作薄      
  if len - 65535 <= 0    
    worksheet = workbook.add_worksheet

    headings = %w(声音名称 分类 是否爬虫 发布用户 发布时间 
                  收听总人数 web端收听人数 mb端收听人数 iphone收听人数 ipad收听人数 chezai收听人数 android收听人数 wp端收听人数
                  收听总次数 web端收听次数 mb端收听次数 iphone收听次数 ipad收听次数 chezai收听次数 android收听次数 wp端收听次数
                  收听总时长 web端收听时长 mb端收听时长 iphone收听时长 ipad收听时长 chezai收听时长 android收听时长 wp端收听时长
                  声音id 用户id)      
    
    bold = workbook.add_format(:bold => 1)

    worksheet.set_column('A:N', 12)
    worksheet.set_row(0, 20, bold)
    worksheet.write('A1', headings)
    worksheet.write('A2', [array_3])
    workbook.close
  else
    start = 0
    over = 65534
    while len > 0 do         
      worksheet = workbook.add_worksheet
      headings = %w(声音名称 分类 是否爬虫 发布用户 发布时间 
                  收听总人数 web端收听人数 mb端收听人数 iphone收听人数 ipad收听人数 chezai收听人数 android收听人数 wp端收听人数
                  收听总次数 web端收听次数 mb端收听次数 iphone收听次数 ipad收听次数 chezai收听次数 android收听次数 wp端收听次数
                  收听总时长 web端收听时长 mb端收听时长 iphone收听时长 ipad收听时长 chezai收听时长 android收听时长 wp端收听时长
                  声音id 用户id)      
    
      bold = workbook.add_format(:bold => 1)

      worksheet.set_column('A:N', 12)
      worksheet.set_row(0, 20, bold)
      worksheet.write('A1', headings)
      # worksheet.write('A2', [data[start..over]])
      array_3[start..over].each_with_index do |v, i|
        worksheet.write(i, 0, v)
      end
      len -= 65535
      start = over + 1        
      if len >= 0 and len <= 65535
        over = over + len
      elsif len > 65535           
        over = over + 65535        
      end
    end
    workbook.close 
  end 

  logger.info "complete"
# end
rescue Redis::TimeoutError
  # CREDIS.with_reconnect{|r| r.get }
  logger_error = Logger.new("#{app_root}/log/script/track.listen.error.log")
  logger_error.info Time.now
  logger_error.info "#{e.class} #{e.message}"
  logger_error.info e.backtrace.join("\n")
rescue Exception => e
  logger_error ||= Logger.new("#{app_root}/log/script/track.listen.error.log")
  logger_error.info Time.now
  logger_error.info "#{e.class} #{e.message}"
  logger_error.info e.backtrace.join("\n")
end

# puts "end"
