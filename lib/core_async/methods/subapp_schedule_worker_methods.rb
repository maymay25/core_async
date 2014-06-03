
require 'core_async_hbaserb'

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
      logger.error "subapp_track_day_download #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
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

  end


end