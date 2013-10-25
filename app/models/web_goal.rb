class WebGoal < ActiveRecord::Base
    
  attr_accessible :id, :member_id, :description, :steps, :kilometers, :calories, :expires_at, :status, :created_at, :updated_at
  
  def self.get_user_goals(userid)
    select("*")
    .find(:first, :conditions => ["member_id = #{userid} and status = 1"])
  end
  
  def self.set_new_goal(userid, description, calories, distance, steps, expires)
    create do |goal|
      goal.member_id = userid
      goal.description = description
      goal.calories = calories
      goal.kilometers = distance
      goal.steps = steps
      goal.expires_at = expires
      goal.status = 1
    end
  end
  
  def self.check_if_expired(userid)
    select("DATEDIFF(expires_at, CURDATE()) AS status")
    .find(:first, :conditions => ["member_id = ? AND status = 1", userid])
  end
  
  def self.goal_change_status(userid)
    goal = self.find(:first, :conditions => [" member_id = ? AND status = 1", userid])
    goal.status = 0
    goal.save
  end
  
  def self.edit_goal(userid, description, calories, distance, steps, expires)
    goal = self.find(:first, :conditions => ["member_id = ? AND status = 1", userid])
    goal.description = description
    goal.calories = calories
    goal.kilometers = distance
    goal.steps = steps
    goal.expires_at = expires
    goal.save
    
    return goal
  end
  
  def self.del_goal(goalID)
    return self.destroy(goalID)
  end
end
