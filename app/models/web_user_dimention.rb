class WebUserDimention < ActiveRecord::Base
  attr_accessible :id, :member_id, :height_value, :height_unit, :weight_unit, :weight_value, :distance , :a_unit, :about_me, :country, :state, :city, :zip, :bv_status, :created_at, :updated_at
  
  def self.create_user_dimention(userid)
    create do |user|
      user.member_id = userid
    end
  end
  
  def self.update_user_dimention(object)
    user = self.where(:member_id => object[:userid]).first
    # user.about_me = object[:about_me]
    user.height_value = Mysql.escape_string(object[:height_value])
    user.height_unit = object[:height_unit]
    user.weight_value = object[:weight_value]
    user.weight_unit = object[:weight_unit]
    user.distance = object[:distance]
    user.country = object[:country]
    user.state = object[:state]
    user.city = object[:city]
    user.zip = object[:zip]
    user.save
    
    return user
  end
  
  def self.update_bv_status(userid)
    user = self.where(:member_id => userid).first
    user.bv_status = 1
    user.save
  end
end