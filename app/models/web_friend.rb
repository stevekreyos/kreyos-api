class WebFriend < ActiveRecord::Base
    
  attr_accessible :id, :member_id, :member_bv_player_id, :invitee_email, :invitee_bv_player_id, :status, :created_at, :updated_at
  
  def self.update_friend_status(userid, friend_uid)
    user = self.find(:first, :conditions ["member_id = '#{userid}' AND member_friend_id = '#{friend_uid}'"])
    user.status = 1
    user.save
    
    #return user
  end
  
  def self.check_if_friend_exist(userid, friend_uid)
    select("*")
    .find(:first, :conditions => ["member_id = ? AND member_friend_id = ?", userid, friend_uid])
  end
  
  def self.save_friend_uid(userid, friend_uid)
    create do |user|
      user.member_id = userid
      user.member_friend_id = friend_uid
      user.status = 0;
    end
  end
  
  def self.get_your_friends(userid)
    select("*")
    .find(:first, :conditions => ["member_id = '#{userid}' AND status = 1"])
  end
  
  def self.get_friend_req(userid)
    select("member_friend_id")
    .where("member_id = ?", userid)
  end
  
  def self.get_pending_friends(userid)
    select("invitee_email")
    .find(:all, :conditions => ["member_id = ? AND status = 0", userid])
  end
  
  
  def self.update_player_bv_id(member_id, email, bv_player_id)
    user = self.where(:member_id => member_id, :invitee_email => email, :status => 0).first
    user.invitee_bv_player_id = bv_player_id
    user.status = 1
    user.save
    return user
  end
  
  def self.add_as_friend(member_id, member_bv_player_id, invitee_email, invitee_bv_player_id)
    create do |friend|
      friend.member_id = member_id
      friend.member_bv_player_id = member_bv_player_id
      friend.invitee_email = invitee_email
      friend.invitee_bv_player_id = invitee_bv_player_id
      friend.status = 1
    end
  end
end
