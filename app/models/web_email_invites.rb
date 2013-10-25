class WebEmailInvites < ActiveRecord::Base
    
  attr_accessible :id, :memberid, :email, :created_at, :updated_at

  def self.save_invites(email, userid)
    create do |user|
      user.member_id = userid
      user.email = email
    end
  end
  
  def self.check_if_email_exist(email, userid)
    select("*")
    .find(:first, :conditions => ["member_id = ? AND email = ?", userid, email])
  end
end