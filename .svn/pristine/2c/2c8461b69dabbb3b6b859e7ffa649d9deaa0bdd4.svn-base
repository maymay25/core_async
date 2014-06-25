
SUBAPP_DB = {
  adapter: 'mysql2',
  encoding: Settings.subapp.encoding,
  reconnect: Settings.subapp.reconnect,
  database: Settings.subapp.database,
  username: Settings.subapp.username,
  password: Settings.subapp.password,
  host: Settings.subapp.host
}

class App < ActiveRecord::Base
  self.table_name = 'tb_app' # 子app
  establish_connection SUBAPP_DB
  attr_accessible :title,
    :name, # 拼音
    :content_type, # 1:多人 2:单人 3:单专辑
    :is_published, # 是否发布过
    :app_icon_path,
    :app_icon_default,
    :app_icon_57_path,
    :app_icon_124_path,
    :background_path,
    :default_background,
    :loading_icon_path, 
    :loading_default,
    :loading_320x480_path, 
    :loading_640x960_path, 
    :loading_640x1136_path, 
    :loading_480x800_path, 
    :loading_1280x720_path, 
    :loading_music_path,
    :loading_music_default,
    :apple_appid,
    :talkingdata_iphone_key,
    :talkingdata_android_key,
    :duomeng_ios_key, # 多盟广告ios版key
    :duomeng_android_key, # 多盟广告android版key
    :googlead_ios_key,
    :googlead_android_key,
    :weixin_ios_key,
    :weixin_android_key,
    :irateid,
    :certificate_name, #打包用的苹果证书名
    :envir, #环境 0：开发 1：测试
    :app_icon_72_path, #android用
    :app_icon_144_path, #android用
    :channel_num, #渠道号
    :baidu_ios_id, :baidu_ios_key, :baidu_android_id, :baidu_android_key, :ios_ads, :android_ads, :ios_is_upgraded, :android_is_upgraded,
    :ios_is_recommended, :android_is_recommended, :ad_id, :is_push, :ios_version, :android_version, :production_id, :skin, :font,
    :is_lite, :ios_is_search, :android_is_search,
    :qq_ios_key, :qq_android_key,
    :qq_ios_id, :qq_android_id,
    :app_icon_120_path, :app_type, :file_url, :certificate_url,
    :ios_is_chaping, :android_is_chaping, :ios_ad_time, :and_ad_time,
    :ios_comment_lock, :android_comment_lock,
    :ios_integral_wall, :android_integral_wall,
    :count, :unlock, :comment, :ximalaya, :other, :ios_force_comment, :android_force_comment,
    :ios_comment_time, :android_comment_time,
    :android_480_skin, :android_720_skin, :android_font, :download,
    :ios_is_bookstore, :android_is_bookstore, :ios_is_upgrade_in_download, :android_is_upgrade_in_download, :ios_is_upgrade_in_play, :android_is_upgrade_in_play,
    :ios_is_rate_pop, :android_is_rate_pop, :ios_time_to_rate, :android_time_to_rate, :old_version_switch, :ios_is_you_mi, :android_is_you_mi, :weixin_share, :is_audit,
    :pad_loading_icon_path, :ios_icon_72_path, :ios_icon_144_path, :ios_icon_76_path, :ios_icon_152_path, :pack_type, :init, :ios_is_audit_bookstore, :ios_is_banner, 
    :ios_is_audit_banner
end

class SelectedAlbums < ActiveRecord::Base
  establish_connection SUBAPP_DB
  self.table_name = 'tb_selected_albums' # 子App分类类型
  attr_accessible :title, :tags, :album_extra_tags, :extra_tags, :order_num, :cover_path, :category_id, :last_uptrack_at, :created_at, :updated_at

  def self.get(selected_album_cache, id)
     selected_album = selected_album_cache.get(id)
     selected_album = self.where(id: id).first if selected_album.nil?
     selected_album_cache.put(selected_album) unless selected_album.nil?
     selected_album
  end 

  def self.mget(selected_album_cache, ids)
    selected_albums = selected_album_cache.multi_get(ids)
    fetch_ids_hash= {}
    fetch_ids = []
    selected_albums.each_with_index do |selected_album, i| 
      if selected_album.nil? 
        fetch_ids << ids[i] 
        fetch_ids_hash[ids[i]] = i
      end
    end

    if fetch_ids.length > 0
      selected_albums_not_hit = self.find(fetch_ids)
      cached_selected_albums = []

      selected_albums_not_hit.each_with_index do |selected_album, i|
        if !selected_album.nil?
          selected_albums[fetch_ids_hash[selected_album.id]] = selected_album
          cached_selected_albums << selected_album
        end
      end

      selected_album_cache.multi_put(cached_selected_albums) if cached_selected_albums.length > 0
    end
    selected_albums
  end

  def self.disable_cache(selected_album_cache, id)
    selected_album_cache.evict(id)
  end
end

class SelectedAlbumsRelation < ActiveRecord::Base
  establish_connection SUBAPP_DB
  self.table_name = 'tb_selected_albums_relation' # 子App分类类型
  attr_accessible :selected_id, :album_id, :updated_at

  def self.get_album_ids(list_ids_cache, selected_album, page, limit)
    id = selected_album.id
    album_ids = nil
    if page == 1
       album_ids = list_ids_cache.get(id, page, limit)
       album_ids = album_ids.collect {|id| id.to_i unless id.nil? || id.empty?}
    end

    if album_ids.nil? || album_ids.length == 0
        select = "album_id"
        album_relations = self.select(select).where(:selected_id=>id).order("field(album_id,#{selected_album.order_num})").offset((page-1)*limit).limit(limit)
        album_ids = album_relations.collect{|album_relation| album_relation.album_id unless album_relation.nil?}
        if page == 1 && album_ids.length > 0 
            list_ids_cache.put(id, album_ids)
        end
    end
    album_ids
  end

  def self.disable_cache(list_ids_cache, id)
    list_ids_cache.evict(id)
  end
end

begin
  Dir[ File.join(Settings.subapp_models_path, '**/*.rb') ].each{|file| require file }
rescue Exception => e
  puts "#{Time.now} load subapp_models failed!!!!!! #{e.class}: #{e.message} \n #{e.backtrace.join("\n")}"
end