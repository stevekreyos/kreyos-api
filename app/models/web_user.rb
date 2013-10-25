class WebUser < ActiveRecord::Base
  
  attr_accessible :id, :bv_id, :provider, :uid, :name, :email, :nickname, :birthday, :gender, :oauth_token, :last_sync, :created_at, :updated_at
  
  def self.create_with_omniauth_facebook(provider, uid, name, email, token, gender, birthday, nickname)
    create do |user|
      user.provider = provider
      user.uid = uid
      user.name = name
      user.email = email
      user.oauth_token = token
      user.birthday = birthday
      user.gender = gender
      user.nickname = nickname
    end
  end
  
  def self.user_info(email)
    return select("*").where("email = #{email}")
  end
  
  def self.update_user(object)
    user = self.where(:id => object[:userid]).first
    user.name = object[:fname]
    user.nickname = object[:nickname]
    # user.birthday = [object[:bd_year], object[:bd_month], object[:bd_day]].join('-')
    user.gender = object[:gender]
    user.save
    return user
  end
    
  def self.get_friend_list(userid)
    select("wu.name, wu.gender, wu.uid, wu.email, wu.id")
    .from("web_users AS wu")
    .joins("INNER JOIN web_friends AS wf ON wu.email = wf.invitee_email")
    .find(:all, :conditions => ["member_id = ? AND status = 1", userid])
  end

  def self.g_name(userid)
    select("name, uid")
    .find(:first, :conditions => ["bv_id = ?", userid])
  end
  
  def self.get_leaderboard_name(userid)
    select("name, uid")
    .find(:first, :conditions => ["bv_player_id = ?", userid])
  end
  
  def self.vg_id(email)
    select("id, email")
    .find(:all, :conditions => ["email =? ", email])
  end
  
  def self.get_friends_player_bv_id(email)
    select("bv_player_id, email")
    .where("email IN (#{email})")
  end
end