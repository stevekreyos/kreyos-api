class WebLeaderboard < ActiveRecord::Base
  
  attr_accessible :id, :name, :calories, :distance_value, :distance_unit, :steps
  
  def self.leaderboard()
    select("*").order("distance_value DESC")
  end

end