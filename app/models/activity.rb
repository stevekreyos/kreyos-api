class Activity < ActiveRecord::Base
  attr_accessible :id, :platform, :email, :order_id, :user_identifier, :action, :views, :bought, :order_id_status, :campaign_id, :created_at
  
  
end