
def establish_connection!
  puts 'establish_connection!'
  ActiveRecord::Base.default_timezone = :local

  ActiveRecord::Base.establish_connection(
    adapter: 'em_mysql2',
    pool: 25,
    encoding: Settings.web.encoding,
    reconnect: Settings.web.reconnect,
    database: Settings.web.database,
    username: Settings.web.username,
    password: Settings.web.password,
    host: Settings.web.host
  )

  Album.define_attribute_methods
  BlockAvatar.define_attribute_methods
  Chat.define_attribute_methods
  Comment.define_attribute_methods
  Favorite.define_attribute_methods
  FavoriteAlbum.define_attribute_methods
  Follower.define_attribute_methods
  FollowerTag.define_attribute_methods
  Following.define_attribute_methods
  Followingx2Group.define_attribute_methods
  FollowingGroup.define_attribute_methods
  FollowingTag.define_attribute_methods
  Inbox.define_attribute_methods
  Linkman.define_attribute_methods
  Lover.define_attribute_methods
  LoverAlbum.define_attribute_methods
  Outbox.define_attribute_methods
  Track.define_attribute_methods
  TrackInRecord.define_attribute_methods
  TrackBlock.define_attribute_methods
  TrackRecord.define_attribute_methods
  TrackRich.define_attribute_methods
  TrackSetRich.define_attribute_methods
  UserTag.define_attribute_methods
end

establish_connection!