require 'hbaserb'
require 'writeexcel'

module CoreAsync

  module SubappScheduleWorkerMethods

    def perform(action,*args)
      method(action).call(*args)
    end

    def subapp_track_day_download

      client = HbaseClient.new(Settings.hbase_ip, 9090)
      client.start

      time = Time.now.to_date - 1.day
      stime = time.to_s.gsub("-","")
      etime = (time + 1.day).to_s.gsub("-","") 
      # cid = client.get_scanner_id("hb_play_track_day", "#{stime}_0_:", "#{etime}")

      # time = ARGV[0].to_date
      # stime = ARGV[0].gsub("-","")
      # etime = (time + 1.day).to_s.gsub("-","")

      # cid = client.get_scanner_id("hb_play_track_day", "#{stime}_0_:", "#{etime}") 

      #新方法取scanner_id
      tscan = Apache::Hadoop::Hbase::Thrift::TScan.new()
      tscan.startRow = "#{stime}_0_:"
      tscan.stopRow = "#{etime}"
      tscan.caching = 1000
      cid = client.get_scanner_id2("hb_play_track_day", tscan)

      #根目录是否存在，不存在则新建
      unless Dir.exist?(Settings.stat_root)
        FileUtils.mkdir_p(Settings.stat_root)
      end
      
      #目录不存在时新建
      unless Dir.exist?("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
        FileUtils.mkdir_p("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
      end

      workbook = WriteExcel.new("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}/#{time}_subapp_track.xls")

      logger.info "#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}/#{time}_subapp_track.xls" 

      # num = 0

      while true
        result = loop_get_track(workbook, 1, client, cid)
        # break if num == 1
        break if result == []
        # num += 1
      end

      workbook.close
      
      client.close_scan(cid)
      client.close
    rescue Exception => e
      logger.error "#{Time.now} #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def subapp_user_day_download
      time = Time.now.to_date - 1.day
      data = search_list(time.to_s)
      
      array_1 = []
      array_3 = []
     
      data.each do |v|
        array_1 << v.values
      end

      array_1.each do |a|   
        array_2 = []
        array_2[0] = a[32] #用户id
        array_2[1] = a[30][0] #是否加V 
        array_2[2] = a[28][0] #总时长 
        array_2[3] = a[31][0] #总声音数
        array_2[4] = a[29][0] #总收听次数
        array_2[5] = a[0][0] #手机时长
        array_2[6] = a[2][0] #手机声音数
        array_2[7] = a[1][0] #手机收听次数
        array_2[8] = a[6][0] #非爬虫收听时长 
        array_2[9] = a[8][0] #非爬虫声音数
        array_2[10] = a[7][0] #非爬虫收听次数
        array_2[11] = a[12][0] #爬虫时长
        array_2[12] = a[14][0] #爬虫声音数
        array_2[13] = a[13][0] #爬虫收听次数
        array_2[14] = a[15][0] #iphone时长
        array_2[15] = a[17][0] #iphone声音数
        array_2[16] = a[16][0] #iphone收听次数
        array_2[17] = a[18][0] #ipad时长
        array_2[18] = a[20][0] #ipad声音数
        array_2[19] = a[19][0] #ipad收听次数
        array_2[20] = a[24][0] #android时长
        array_2[21] = a[26][0] #android声音数
        array_2[22] = a[25][0] #android收听次数
        array_2[23] = a[27]    #子appid
        
        array_3 << array_2
      end

      #根目录是否存在，不存在则新建
      unless Dir.exist?(Settings.stat_root)
        FileUtils.mkdir_p(Settings.stat_root)
      end

      #目录不存在时新建
      unless Dir.exist?("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
        FileUtils.mkdir_p("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}")
      end

      data = array_3
      len = data.size

      workbook = WriteExcel.new("#{Settings.stat_root}/#{time.year}/m/#{time.month}/#{time.day}/#{time}_subapp_user.xls") 
      
      #一页最多65536行,大于的新建工作薄      
      if len - 65535 <= 0    
        worksheet = workbook.add_worksheet

        headings = %w(用户 是否加V 总时长 总声音数 总收听次数 手机时长 手机声音数 手机收听次数 
                      非爬虫时长 非爬虫声音数 非爬虫收听次数 爬虫时长 爬虫声音数 爬虫收听次数 
                      iphone时长 iphone声音数 iphone收听次数 ipad时长 ipad声音数 ipad收听次数 
                      android时长 android声音数 android收听次数 子appid)     
        
        bold = workbook.add_format(:bold => 1)

        worksheet.set_column('A:N', 12)
        worksheet.set_row(0, 20, bold)
        worksheet.write('A1', headings)
        worksheet.write('A2', [data])
        workbook.close
      else
        start = 0
        over = 65534
        while len > 0 do
          worksheet = workbook.add_worksheet
          headings = %w(用户 是否加V 总时长 总声音数 总收听次数 手机时长 手机声音数 手机收听次数
                        非爬虫时长 非爬虫声音数 非爬虫收听次数 爬虫时长 爬虫声音数 爬虫收听次数 
                        iphone时长 iphone声音数 iphone收听次数 ipad时长 ipad声音数 ipad收听次数 
                        android时长 android声音数 android收听次数 子appid)      
        
          bold = workbook.add_format(:bold => 1)

          worksheet.set_column('A:N', 12)
          worksheet.set_row(0, 20, bold)
          worksheet.write('A1', headings)
          worksheet.write('A2', [data[start..over]])
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
    rescue Exception => e
      logger.error "#{Time.now} #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    private

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/sidekiq/subapp_schedule#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end

    #循环调用此方法，读取数据  used by `subapp_track_day_download`
    def loop_get_track(wb, len, client, cid, is_subapp = true)
      worksheet = wb.add_worksheet

      headings = %w(声音名称 分类 是否爬虫 发布用户 发布时间 
                    收听总人数 web端收听人数 mb端收听人数 iphone收听人数 ipad收听人数 chezai收听人数 android收听人数 wp端收听人数
                    收听总次数 大于0s 小于5s web端收听次数 大于0s 小于5s mb端收听次数 大于0s 小于5s iphone收听次数 大于0s 小于5s
                    ipad收听次数 大于0s 小于5s chezai收听次数 大于0s 小于5s android收听次数 大于0s 小于5s wp端收听次数 大于0s 小于5s
                    收听总时长 web端收听时长 mb端收听时长 iphone收听时长 ipad收听时长 chezai收听时长 android收听时长 wp端收听时长
                    声音id 用户id 子appid)
      
      bold = wb.add_format(:bold => 1)

      worksheet.set_column('A:N', 12)
      worksheet.set_row(0, 20, bold)
      worksheet.write('A1', headings)
      while true
        break if len == 65001
        status = client.get_re(cid, is_subapp)
        break if status == []
        status.each_with_index do |f,i|
          worksheet.write(len + i, 0, f)
        end
        len += 1000
      end

      # len = 1
      status
    end

    # 查询方法
    def search_list(day)
      table_name = "hb_play_user_day"
      start_time = day.gsub('-','')
      end_time = (day.to_date + 1.day).to_s.gsub('-','')  
       
      client = HbaseClient.new(Settings.hbase_ip, 9090)
      client.start  
      return client.scanner_subapp_user(table_name,start_time,end_time) 
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

  end


end