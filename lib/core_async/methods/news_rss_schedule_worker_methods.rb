module CoreAsync

  module NewsRssScheduleWorkerMethods

    include CoreHelper

    def perform(action,*args)
      method(action).call(*args)
    end

    def gen_neteasenews_rss
      xml = '<?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel><copyright>Copyright @喜马拉雅 www.ximalaya.com</copyright><language>zh-cn</language><users>'

      Settings.neteasenews_uids.each do |uid|
        user = $profile_client.queryUserBasicInfo(uid)
        xml << "\n<user>"
        xml << "\n<uid>#{uid}</uid>"
        xml << "\n<nickname>#{CGI.escapeHTML(user.nickname) if user.nickname}</nickname>"
        xml << "\n<headurl>#{picture_url('user', user.logoPic, 'origin')}</headurl>"
        xml << "\n<link>http://www.ximalaya.com/#{uid}</link>"
        xml << "\n<tracks>"
        TrackRecord.shard(uid).where(uid: uid, is_deleted: false, is_public: true, status: 1).order('created_at desc').limit(10).each do |record|
          url = file_url(record.play_path_64)
          albumurl = "http://www.ximalaya.com/#{record.track_uid}/album/#{record.album_id}" if record.album_id
          xml << "\n<track>"
          xml << "\n<album>#{CGI.escapeHTML(record.album_title) if record.album_title}</album>"
          xml << "\n<albumurl>#{albumurl}</albumurl>"
          xml << "\n<title>#{CGI.escapeHTML(record.title) if record.title}</title>"
          xml << "\n<summary>#{CGI.escapeHTML(record.intro) if record.intro}</summary>"
          xml << "\n<image>#{picture_url('track', record.cover_path, 'origin')}</image>"
          xml << "\n<url>http://www.ximalaya.com/jt.mp3?channel=neteasenews&amp;album_id=#{record.album_id}&amp;track_id=#{record.track_id}&amp;uid=#{record.uid}&amp;jt=#{url}\</url>"
          xml << "\n<pubdate>#{record.created_at.strftime('%a, %e %b %Y %T %z')}</pubdate>"
          xml << "\n<duration>#{parse_duration(record.duration)}</duration>"
          xml << "\n</track>"
        end
        xml << "\n</tracks>"
        xml << "\n</user>"
      end

      xml << '</users></channel></rss>'

      $redis.set(Settings.pagedata.neteasenews, xml)
    rescue Exception => e
      logger.error "gen_neteasenews_rss #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def gen_sohunews_rss
      now = Time.new

      xml = '<?xml version="1.0" encoding="UTF-8"?>'
      xml << "<rss xmlns:atom=\"http://www.w3.org/2005/Atom\" xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\" version=\"2.0\"><channel>"
      xml << '<atom:link href="http://rss.ximalaya.com/sohunews" type="application/rss+xml" rel="self"></atom:link>'
      xml << '<copyright>Copyright @喜马拉雅 www.ximalaya.com</copyright>'
      xml << '<language>zh-cn</language>'
      xml << '<link>http://www.ximalaya.com</link>'
      xml << "<title>喜马拉雅app</title>"
      xml << "<description>喜马拉雅 听我想听</description>"

      Settings.neteasenews_uids.each do |uid|
        TrackRecord.shard(uid).where('uid = ? and status = 1 and is_deleted = 0 and is_public = 1 and created_at > ?', uid, now - 604800).order('created_at desc').limit(10).each do |record|
          url = file_url(record.play_path_64)
          jt_path = "/jt.mp3?channel=sohunews&amp;album_id=#{record.album_id}&amp;track_id=#{record.track_id}&amp;uid=#{record.uid}&amp;jt=#{url}"
          xml << "\n<item>"
          xml << "\n<title>#{CGI.escapeHTML(record.title) if record.title}</title>"
          xml << "\n<enclosure url=\"#{File.join(Settings.home_root, jt_path)}\" type=\"text/html\" length=\"#{record.mp3size_64}\" />"
          xml << "\n<link>#{[ Settings.home_root, record.track_uid, 'sound', record.track_id ].join('/')}</link>"
          xml << "\n<description>#{CGI.escapeHTML(record.intro) if record.intro}</description>"
          xml << "\n<itunes:author>#{CGI.escapeHTML(record.nickname) if record.nickname}</itunes:author>"
          xml << "\n<itunes:image href=\"#{picture_url('track', record.cover_path, 'origin')}\" />"
          xml << "\n<pubDate>#{record.created_at.strftime('%a, %e %b %Y %T %z')}</pubDate>"
          xml << "\n<guid>#{url}</guid>"
          xml << "\n<itunes:duration>#{parse_duration(record.duration)}</itunes:duration>"
          xml << "\n<itunes:subtitle>#{CGI.escapeHTML(record.album_title) if record.album_title}</itunes:subtitle>"
          xml << "\n</item>"
        end
      end

      xml << '</channel></rss>'

      $redis.set(Settings.pagedata.sohunews, xml)
    rescue Exception => e
      logger.error "gen_sohunews_rss #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def gen_hnxxt_rss
      xml = '<?xml version="1.0" encoding="UTF-8"?>'
      xml << "<rss xmlns:atom=\"http://www.w3.org/2005/Atom\" xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\" version=\"2.0\"><channel>"
      xml << '<atom:link href="http://rss.ximalaya.com/hnxxt" type="application/rss+xml" rel="self"></atom:link>'
      xml << '<copyright>Copyright @喜马拉雅 www.ximalaya.com</copyright>'
      xml << '<language>zh-cn</language>'
      xml << '<link>http://www.ximalaya.com</link>'
      xml << "<title>河南新乡台 喜马拉雅app</title>"
      xml << "<description>喜马拉雅 听我想听</description>"

      # 糗事百科，段子来了
      [ 1000596, 2629294 ].each do |uid|
        TrackRecord.shard(uid).where('uid = ? and status = 1 and is_deleted = 0 and is_public = 1', uid).order('created_at desc').each do |record|
          url = file_url(record.play_path_64)
          jt_path = "/jt.mp3?channel=hnxxt&amp;album_id=#{record.album_id}&amp;track_id=#{record.track_id}&amp;uid=#{record.uid}&amp;jt=#{url}"
          xml << "\n<item>"
          xml << "\n<title>#{CGI.escapeHTML(record.title) if record.title}</title>"
          xml << "\n<enclosure url=\"#{File.join(Settings.home_root, jt_path)}\" type=\"text/html\" length=\"#{record.mp3size_64}\" />"
          xml << "\n<link>#{[ Settings.home_root, record.track_uid, 'sound', record.track_id ].join('/')}</link>"
          xml << "\n<description>#{CGI.escapeHTML(record.intro) if record.intro}</description>"
          xml << "\n<itunes:author>#{CGI.escapeHTML(record.nickname) if record.nickname}</itunes:author>"
          xml << "\n<itunes:image href=\"#{picture_url('track', record.cover_path, 'origin')}\" />"
          xml << "\n<pubDate>#{record.created_at.strftime('%a, %e %b %Y %T %z')}</pubDate>"
          xml << "\n<guid>#{url}</guid>"
          xml << "\n<itunes:duration>#{parse_duration(record.duration)}</itunes:duration>"
          xml << "\n<itunes:subtitle>#{CGI.escapeHTML(record.album_title) if record.album_title}</itunes:subtitle>"
          xml << "\n</item>"
        end
      end

      xml << '</channel></rss>'

      $redis.set('hnxxt', xml)
    rescue Exception => e
      logger.error "gen_hnxxt_rss #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    def gen_hnsjt_rss
      now = Time.new

      xml = '<?xml version="1.0" encoding="UTF-8"?>'
      xml << "<rss xmlns:atom=\"http://www.w3.org/2005/Atom\" xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\" version=\"2.0\"><channel>"
      xml << '<atom:link href="http://rss.ximalaya.com/hnsjt" type="application/rss+xml" rel="self"></atom:link>'
      xml << '<copyright>Copyright @喜马拉雅 www.ximalaya.com</copyright>'
      xml << '<language>zh-cn</language>'
      xml << '<link>http://www.ximalaya.com</link>'
      xml << "<title>河南手机台 喜马拉雅app</title>"
      xml << "<description>喜马拉雅 听我想听</description>"
      [
          [ 4889, 1000355 ],
          [ 4888, 1000355 ],
          [ 4887, 1000355 ],
          [ 4886, 1000355 ],
          [ 797, 1000355 ],

          [ 214002, 1344508 ],
          [ 213998, 1344508 ],
          [ 213996, 1344508 ],

          [ 5211, 1368328 ],
          [ 5210, 1368328 ],
          [ 5209, 1368328 ],

          [ 4885, 1000341 ],
          [ 4884, 1000341 ],
          [ 4883, 1000341 ],

          [ 214013, 1000334 ],
          [ 214011, 1000334 ],

          [ 213334, 3570632 ],

          [ 214146, 3636417 ],

          [ 214153, 1000334 ],
          [ 214150, 1000334 ],

          [ 194266, 1247478 ],
          [ 194265, 1247478 ],
          [ 194264, 1247478 ],

          [ 214716, 1000402 ],
          [ 214465, 1000402 ],
          [ 214452, 1000402 ],
          [ 214442, 1000402 ],

          [ 15815, 1247518 ],
          [ 15814, 1247518 ],

          [ 214568, 3636417 ],
          [ 214567, 3636417 ],

          [ 15821, 1728571 ],
          [ 15820, 1728571 ],
          [ 15819, 1728571 ],

          [ 195226, 1247518 ],
          [ 195225, 1247518 ],

          [ 4984, 1000326 ],
          [ 4983, 1000326 ],
          [ 4982, 1000326 ],
          [ 4981, 1000326 ],
          [ 4980, 1000326 ],
          [ 4979, 1000326 ],
          [ 1807, 1000326 ],

          [ 2482, 1000334 ],

          [ 2508, 1000334 ],

          [ 5215, 1368324 ],
          [ 5214, 1368324 ],
          [ 5213, 1368324 ],

          [ 194208, 2072952 ],
          [ 194192, 2072952 ],

          [ 197910, 1247543 ],
          [ 197908, 1247543 ],

          [ 4892, 1000257 ],
          [ 4891, 1000257 ],
          [ 4890, 1000257 ],

          [ 236052, 6140066 ],

          [ 5331, 1247543 ],
          [ 5330, 1247543 ],

          [ 194679, 2131901 ],

          [ 214624, 1000257 ],

          [ 194750, 1247417 ],
          [ 194211, 1247417 ],

          [ 195099, 1247417 ],

          [ 214623, 3583518 ],
          [ 214621, 3583518 ],
          [ 214620, 3583518 ],
          [ 214618, 3583518 ],

          [ 195001, 2072952 ],

          [ 192250, 1247500 ],
          [ 192200, 1247500 ],

          [ 15695, 1000366 ],
          [ 15694, 1000366 ],
          [ 15693, 1000366 ],
          [ 15692, 1000366 ],

          [ 214625, 3636417 ],

          [ 225072, 1247518 ],

          [ 194033, 1873479 ],

          [ 196567, 1873479 ],

          [ 193463, 2072952 ],

          [ 205394, 1000338 ],
          [ 4009, 1000338 ],
          [ 1605, 1000338 ],
          [ 1603, 1000338 ],
          [ 1602, 1000338 ],
          [ 1601, 1000338 ],
          [ 1600, 1000338 ],
          [ 1599, 1000338 ],
          [ 1598, 1000338 ],
          [ 1596, 1000338 ],
          [ 1592, 1000338 ],
          [ 1587, 1000338 ],
          [ 1585, 1000338 ],
          [ 1583, 1000338 ],
          [ 1581, 1000338 ],
          [ 1580, 1000338 ],
          [ 1579, 1000338 ],

          [ 194932, 2343399 ],
          [ 194928, 2343399 ],
          [ 194927, 2343399 ],
          [ 194781, 2343399 ],

          [ 193823, 1873535 ],
          [ 193813, 1873535 ],
          [ 193811, 1873535 ],

          [ 15709, 1247543 ],

          [ 214741, 1247518 ],
          [ 214738, 1247518 ],

          [ 192553, 2072952 ],
          [ 192381, 2072952 ],

          [ 15877, 1247543 ],

          [ 193576, 1247478 ],
          [ 193574, 1247478 ],

          [ 192257, 2072952 ],
          [ 192130, 2072952 ],

          [ 197790, 1247543 ],
          [ 197713, 1247543 ],

          [ 214745, 1000334 ],
          [ 214744, 1000334 ],

          [ 2610, 1000259 ],

          [ 1479, 1000298 ],

          [ 16299, 1000334 ],

          [ 1699, 1000341 ],
          [ 1698, 1000341 ],
          [ 1697, 1000341 ],
          [ 1696, 1000341 ],
          [ 1695, 1000341 ],
          [ 1694, 1000341 ],
          [ 1693, 1000341 ],
          [ 1692, 1000341 ],
          [ 1691, 1000341 ],
          [ 1690, 1000341 ],
          [ 1689, 1000341 ],

          [ 225557, 4783608 ],

          [ 225567, 1247478 ],

          [ 218914, 1689386 ],
          [ 215668, 1689386 ],
          [ 215602, 1689386 ],
          [ 215101, 3636417 ],
          [ 214584, 1689386 ],
          [ 214523, 1689386 ],

          [ 215106, 1000383 ],
          [ 215105, 1000383 ],
          [ 215104, 1000383 ],

          [ 4300, 1000357 ],
          [ 4299, 1000357 ],
          [ 4298, 1000357 ],
          [ 4297, 1000357 ],
          [ 3440, 1000357 ],

          [ 216529, 1000350 ],

          [ 216259, 1000262 ],

          [ 5163, 1000331 ],
          [ 5162, 1000331 ],
          [ 5161, 1000331 ],
          [ 2067, 1000331 ],

          [ 192475, 1873479 ],

          [ 5160, 1000354 ],
          [ 5159, 1000354 ],
          [ 5158, 1000354 ],
          [ 5157, 1000354 ],
          [ 5156, 1000354 ],
          [ 2123, 1000354 ],


          [ 225423, 1000332 ],

          [ 15710, 1247543 ],

          [ 3646, 1000334 ],

          [ 194515, 2131901 ],

          [ 5811, 1247518 ],

          [ 5117, 1000347 ],
          [ 5116, 1000347 ],
          [ 5115, 1000347 ],
          [ 5114, 1000347 ],
          [ 5113, 1000347 ],
          [ 965, 1000347 ],

          [ 1662, 1000339 ],
          [ 1655, 1000339 ],
          [ 1648, 1000339 ],
          [ 1646, 1000339 ],
          [ 1640, 1000339 ],
          [ 1639, 1000339 ],
          [ 1638, 1000339 ],
          [ 1637, 1000339 ],
          [ 1636, 1000339 ],
          [ 1635, 1000339 ],
          [ 1634, 1000339 ],
          [ 1623, 1000339 ],
          [ 1621, 1000339 ],

          [ 1674, 1000325 ],
          [ 1673, 1000325 ],
          [ 1672, 1000325 ],
          [ 1671, 1000325 ],
          [ 1670, 1000325 ],
          [ 1669, 1000325 ],
          [ 1668, 1000325 ],

          [ 215272, 1000257 ],

          [ 231841, 1023016 ],
          [ 231820, 1023016 ],
          [ 231812, 1023016 ],

          [ 192109, 1247417 ],

          [ 223867, 1000397 ],
          [ 2711, 1000397 ],

          [ 223838, 1000323 ],
          [ 223837, 1000323 ],
          [ 223836, 1000323 ],
          [ 223834, 1000323 ],

          [ 5391, 1247543 ],

          [ 3576, 1000360 ],

          [ 4294, 1000258 ],

          [ 192482, 1247417 ],

          [ 215515, 3879622 ],
          [ 215510, 3879622 ],
          [ 215506, 3879622 ],

          [ 215524, 3884792 ],
          [ 215520, 3884792 ],
          [ 215517, 3884792 ],

          [ 3441, 1000259 ],

          [ 15947, 1247518 ],
          [ 15946, 1247518 ],

          [ 3782, 1000334 ],

          [ 215613, 1000358 ],
          [ 215598, 1000358 ],

          [ 215640, 1000396 ],
          [ 215639, 1000396 ],
          [ 215637, 1000396 ],
          [ 215621, 1000396 ],

          [ 3854, 1000258 ],

          [ 208070, 1247478 ],
          [ 208048, 1247478 ],
          [ 208045, 1247478 ],

          [ 5397, 1247417 ],

          [ 221, 1000307 ],

          [ 5377, 1000327 ],
          [ 5376, 1000327 ],
          [ 5375, 1000327 ],
          [ 5374, 1000327 ],
          [ 5373, 1000327 ],
          [ 5372, 1000327 ],
          [ 5371, 1000327 ],
          [ 1456, 1000327 ],

          [ 197928, 1247543 ],

          [ 3582, 1000399 ],

          [ 216031, 1247417 ],
          [ 216027, 1247417 ],

          [ 896, 1000400 ],

          [ 215750, 1000371 ],
          [ 215747, 1000371 ],
          [ 215745, 1000371 ],
          [ 215738, 1000371 ],
          [ 215728, 1000371 ],
          [ 215706, 1000371 ],

          [ 217221, 4047101 ],
          [ 217217, 4047101 ],
          [ 217212, 4047101 ],

          [ 216054, 3937779 ],
          [ 216053, 3937779 ],
          [ 216052, 3937779 ],
          [ 216037, 3937779 ],

          [ 217626, 1000258 ],

          [ 217627, 1000332 ],

          [ 216284, 1000334 ],

          [ 217108, 1000333 ],

          [ 217848, 1247543 ],

          [ 3886, 1000334 ],

          [ 217207, 1000386 ],
          [ 217204, 1000386 ],

          [ 197649, 1247500 ],
          [ 197554, 1247500 ],

          [ 192163, 1247417 ],

          [ 5747, 1247518 ],
          [ 5746, 1247518 ],

          [ 217331, 1000401 ],
          [ 217330, 1000401 ],

          [ 217338, 1000328 ],
          [ 217337, 1000328 ],
          [ 217336, 1000328 ],
          [ 217335, 1000328 ],
          [ 217334, 1000328 ],

          [ 217849, 1000332 ],

          [ 4834, 1247417 ],

          [ 218916, 1000356 ],
          [ 218915, 1000356 ],
          [ 218913, 1000356 ],

          [ 217625, 4096140 ],
          [ 217615, 4096140 ],
          [ 217610, 4096140 ],
          [ 217606, 4096140 ],

          [ 197077, 1873479 ],

          [ 218221, 1000378 ],
          [ 218215, 1000378 ],

          [ 218225, 4138334 ],

          [ 218529, 4139390 ],

          [ 219039, 4140421 ],
          [ 219038, 4140421 ],

          [ 218822, 4176421 ],
          [ 218816, 4176421 ],
          [ 218814, 4176421 ],

          [ 219059, 1000368 ],
          [ 219055, 1000368 ],
          [ 854, 1000368 ],

          [ 194760, 1247478 ],

          [ 219070, 4220056 ],

          [ 195223, 1873535 ],

          [ 211802, 1852539 ],
          [ 211795, 1852539 ],
          [ 211792, 1852539 ],

          [ 220535, 4236996 ],
          [ 220525, 4236996 ],

          [ 220540, 1000398 ],

          [ 220548, 1247500 ],

          [ 220829, 1000346 ],
          [ 220825, 1000346 ],
          [ 220818, 1000346 ],

          [ 221003, 3636417 ],

          [ 221692, 1000332 ],

          [ 220990, 3636417 ],
          [ 220987, 3636417 ],

          [ 221699, 1000334 ],
          [ 221697, 1000334 ],

          [ 221874, 1000332 ],

          [ 221877, 1000258 ],

          [ 221883, 1000262 ],

          [ 222241, 4389911 ],
          [ 222237, 4389911 ],

          [ 222245, 4391640 ],
          [ 222244, 4391640 ],
          [ 222243, 4391640 ],

          [ 197994, 1247543 ],

          [ 222540, 1247417 ],

          [ 222479, 4412789 ],

          [ 222482, 1873479 ],

          [ 222543, 1247478 ],

          [ 192385, 1247417 ],

          [ 222534, 4414172 ],

          [ 222496, 4415339 ],

          [ 222547, 1769838 ],

          [ 2300, 1000334 ],

          [ 223007, 3636417 ],
          [ 223000, 3636417 ],

          [ 1568, 1000364 ],

          [ 225834, 1873479 ],

          [ 225419, 1000332 ],

          [ 225840, 1873479 ] 
      ].each do |album_id, uid|
        TrackRecord.shard(uid).where('uid = ? and album_id = ? and created_at > ? and is_deleted = 0', uid, album_id, now - 2592000).order('created_at desc').each do |record|
          url = file_url(record.play_path_64)
          jt_path = "/jt.mp3?channel=hnsjt&amp;album_id=#{record.album_id}&amp;track_id=#{record.track_id}&amp;uid=#{record.uid}&amp;jt=#{url}"
          xml << "\n<item>"
          xml << "\n<title>#{CGI.escapeHTML(record.title) if record.title}</title>"
          xml << "\n<enclosure url=\"#{File.join(Settings.home_root, jt_path)}\" type=\"text/html\" length=\"#{record.mp3size_64}\" />"
          xml << "\n<link>#{[ Settings.home_root, record.track_uid, 'sound', record.track_id ].join('/')}</link>"
          xml << "\n<description>#{CGI.escapeHTML(record.intro) if record.intro}</description>"
          xml << "\n<itunes:author>#{CGI.escapeHTML(record.nickname) if record.nickname}</itunes:author>"
          xml << "\n<itunes:image href=\"#{picture_url('track', record.cover_path, 'origin')}\" />"
          xml << "\n<pubDate>#{record.created_at.strftime('%a, %e %b %Y %T %z')}</pubDate>"
          xml << "\n<guid>#{url}</guid>"
          xml << "\n<itunes:duration>#{parse_duration(record.duration)}</itunes:duration>"
          xml << "\n<itunes:subtitle>#{CGI.escapeHTML(record.album_title) if record.album_title}</itunes:subtitle>"
          xml << "\n</item>"
        end
      end

      xml << '</channel></rss>'

      $redis.set('hnsjt', xml)
    rescue Exception => e
      logger.error "#{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
      raise e
    end

    private

    def logger
      current_day = Time.now.strftime('%Y-%m-%d')
      if (@@day||=nil) != current_day
        @@logger = ::Logger.new(Sinarey.root+"/log/sidekiq/news_rss_schedule#{current_day}.log")
        @@logger.level = Logger::INFO
        @@day = current_day
      end
      @@logger
    end

  end

end