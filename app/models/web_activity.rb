class WebActivity < ActiveRecord::Base
  
  attr_accessible :id, :member_id, :a_value, :a_unit, :created_at, :updated_at


#**************  DASHBOARD START  ********************#

# => Dashboard Chart Query Start ==========================================================================================
  def self.get_dashboard_calories_chart(userid)
    select("a_value AS value, a_unit AS unit, DATE_FORMAT(created_at, '%l%p') AS hour")
    .group("HOUR(created_at)")
    .where("DATE(created_at) = CURDATE() AND member_id = '#{userid}' AND a_unit = 'calories'")
  end
  
  def self.get_dashboard_steps_chart(userid)
    select("a_value AS value, a_unit AS unit, DATE_FORMAT(created_at, '%l%p') AS hour")
    .group("HOUR(created_at)")
    .where("DATE(created_at) = CURDATE() AND member_id = '#{userid}' AND a_unit = 'steps'")
  end
  
  def self.get_dashboard_km_chart(userid)
    select("a_value AS value, a_unit AS unit, DATE_FORMAT(created_at, '%l%p') AS hour")
    .group("HOUR(created_at)")
    .where("DATE(created_at) = CURDATE() AND member_id = '#{userid}' AND a_unit = 'km'")
  end
# => Dashboard Chart Query End ==========================================================================================

#**************  DASHBOARD END  ********************#


#**************  ACTIVITIES START  ********************#

# => Daily Start ==========================================================================================  
  def self.get_daily_calories(userid)
    select("SUM(a_value) AS calories")
    .find(:first, :conditions => ["DATE(created_at) = CURDATE() AND member_id = '#{userid}' AND a_unit = 'calories'"])
  end
  
  def self.get_daily_ditance(userid)
    select("SUM(a_value) AS value, a_unit AS unit")
    .find(:first, :conditions => ["DATE(created_at) = CURDATE() AND member_id = '#{userid}' AND a_unit = 'km'"])
  end
  
  def self.get_daily_steps(userid)
    select("SUM(a_value) AS steps")
    .find(:first, :conditions => ["DATE(created_at) = CURDATE() AND member_id = '#{userid}' AND a_unit = 'steps'"])
  end
  
  def self.get_daily_chart(userid)
    select("a_value AS value, a_unit AS unit, DATE_FORMAT(created_at, '%l%p') AS hour")
    .group("HOUR(created_at)")
    .where("DATE(created_at) = CURDATE() AND member_id = '#{userid}' AND a_unit = 'km'")
  end
  
  def self.get_daily_most_active(userid)
    select("DATE_FORMAT(created_at, '%l:00%p') AS active_hour")
    .group("a_value DESC")
    .find(:first, :conditions => ["DATE(created_at) = CURDATE() AND member_id = '#{userid}' AND a_unit = 'km'"])
  end
# => Daily End ===========================================================================================



# => Weekly Start ==========================================================================================
  def self.get_weekly_calories(userid)
    select("SUM(a_value) AS calories")
    .find(:first, :conditions => ["WEEK(created_at) = WEEK(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'calories'"])
    #.find(:first, :conditions => ["MONTH(created_at) = MONTH(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'calories'"])
  end
  
  def self.get_weekly_distance(userid)
    select("SUM(a_value) AS value")
     .find(:first, :conditions => ["WEEK(created_at) = WEEK(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'km'"])
    #.find(:first, :conditions => ["MONTH(created_at) = MONTH(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'km'"])
  end
  
  def self.get_weekly_steps(userid)
    select("SUM(a_value) AS steps")
     .find(:first, :conditions => ["WEEK(created_at) = WEEK(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'steps'"])
    #.find(:first, :conditions => ["MONTH(created_at) = MONTH(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'steps'"])
  end
  
  def self.get_weekly_chart(userid)    
    select("SUM(a_value) AS value, DATE_FORMAT(created_at, '%a') AS day")
    .group("day")
    .where("(WEEK(created_at,5) - WEEK(DATE_SUB(created_at, INTERVAL DAYOFMONTH(created_at)-1 DAY),5)+1 ) = (WEEK(CURDATE(),5) - WEEK(DATE_SUB(CURDATE(), INTERVAL DAYOFMONTH(CURDATE())-1 DAY),5)+1 ) AND member_id = '#{userid}' AND a_unit = 'km'")
  end
  
  def self.get_weekly_most_active_day(userid)
    select("DATE_FORMAT(created_at, '%W') AS day")
    .group("a_value DESC")
    .find(:first, :conditions => ["(WEEK(created_at,5) - WEEK(DATE_SUB(created_at, INTERVAL DAYOFMONTH(created_at)-1 DAY),5)+1 ) = (WEEK(CURDATE(),5) - WEEK(DATE_SUB(CURDATE(), INTERVAL DAYOFMONTH(CURDATE())-1 DAY),5)+1 ) AND member_id = '#{userid}' AND a_unit = 'km'"])
  end
# => Weekly End ==========================================================================================  
  
  

# => Monthly Start ==========================================================================================
   def self.get_monthly_calories(userid)
     select("SUM(a_value) AS calories")
     .find(:first, :conditions => ["MONTH(created_at) = MONTH(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'calories'"])
    #.find(:first, :conditions => ["(WEEK(created_at,5) - WEEK(DATE_SUB(created_at, INTERVAL DAYOFMONTH(created_at)-1 DAY),5)+1 ) = (WEEK(CURDATE(),5) - WEEK(DATE_SUB(CURDATE(), INTERVAL DAYOFMONTH(CURDATE())-1 DAY),5)+1 ) AND member_id = '#{userid}' AND a_unit = 'calories'"])
   end
   
   def self.get_monthly_distance(userid)
     select("SUM(a_value) AS value")
     .find(:first, :conditions => ["MONTH(created_at) = MONTH(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'km'"])
    #.find(:first, :conditions => ["(WEEK(created_at,5) - WEEK(DATE_SUB(created_at, INTERVAL DAYOFMONTH(created_at)-1 DAY),5)+1 ) = (WEEK(CURDATE(),5) - WEEK(DATE_SUB(CURDATE(), INTERVAL DAYOFMONTH(CURDATE())-1 DAY),5)+1 ) AND member_id = '#{userid}' AND a_unit = 'km'"])
   end
   
   def self.get_monthly_steps(userid)
     select("SUM(a_value) AS steps")
     .find(:first, :conditions => ["MONTH(created_at) = MONTH(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'steps'"])
    #.find(:first, :conditions => ["(WEEK(created_at,5) - WEEK(DATE_SUB(created_at, INTERVAL DAYOFMONTH(created_at)-1 DAY),5)+1 ) = (WEEK(CURDATE(),5) - WEEK(DATE_SUB(CURDATE(), INTERVAL DAYOFMONTH(CURDATE())-1 DAY),5)+1 ) AND member_id = '#{userid}' AND a_unit = 'steps'"])
   end
   
  def self.get_monthly_chart(userid)
    select("SUM(a_value) AS value, (WEEK(created_at,5) - WEEK(DATE_SUB(created_at, INTERVAL DAYOFMONTH(created_at)-1 DAY),5)+1 ) AS week")
    .group("week")
    .where("MONTH(created_at) = MONTH(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'km'")
  end
  
  def self.get_monthly_most_active_week(userid)
    select("MAX(WEEK(created_at,5) - WEEK(DATE_SUB(created_at, INTERVAL DAYOFMONTH(created_at)-1 DAY),5)+1 ) AS week")
    .group("a_value DESC")
    .find(:first, :conditions => ["MONTH(created_at) = MONTH(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'km'"])
  end
# => Monthly End ==========================================================================================



# => Yearly Start ==========================================================================================
  def self.get_yearly_calories(userid)
    select("SUM(a_value) AS calories")
    .find(:first, :conditions => ["YEAR(created_at) = YEAR(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'calories'"])
  end
  
  def self.get_yearly_distance(userid)
    select("SUM(a_value) AS value")
    .find(:first, :conditions => ["YEAR(created_at) = YEAR(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'km'"])
  end
  
  def self.get_yearly_steps(userid)
    select("SUM(a_value) AS steps")
    .find(:first, :conditions => ["YEAR(created_at) = YEAR(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'steps'"])
  end
  
  def self.get_yearly_chart(userid)
    select("SUM(a_value) AS value, DATE_FORMAT(created_at, '%b') as month")
    .group("month")
    .where("YEAR(created_at) = YEAR(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'km'")
  end
  
  def self.get_yearly_most_active_month(userid)
    select("DATE_FORMAT(created_at, '%M') as month")
    .group("a_value DESC")
    .find(:first, :conditions => ["YEAR(created_at) = YEAR(CURDATE()) AND member_id = '#{userid}' AND a_unit = 'km'"])
  end
# => Yearly End ==========================================================================================

#**************  ACTIVITIES END  ********************#

  # Max Kilometer (km)
  def self.get_fastest_mile(unit, member_id)
    select("MAX(a_value) AS km")
    .find(:first, :conditions => ["a_unit = ? AND member_id = ?", unit, member_id])
  end
  
  # Min Kilometer (km)
  def self.get_longest_run(unit, member_id)
    select("MIN(a_value) AS km")
    .find(:first, :conditions => ["a_unit = ? AND member_id = ?", unit, member_id])
  end

end