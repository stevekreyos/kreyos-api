class WebComment < ActiveRecord::Base
    
  attr_accessible :id, :memberid, :comment, :date
  
  def self.comments
    select("wc.*, wu.name")
    .from("web_comments AS wc")
    .joins("INNER JOIN web_users AS wu ON wc.member_id = wu.id")
    .order("wc.date DESC")
  end
  

end