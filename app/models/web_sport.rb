class WebSport < ActiveRecord::Base
    
  attr_accessible :id, :memberid, :category_name
  
  def self.sports_list()
    select("*")
  end

end