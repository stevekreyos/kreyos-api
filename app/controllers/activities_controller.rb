class ActivitiesController < ApplicationController
  
  include GeneralModule
  
  def show_all
    m = params[:metric]
    if m == 'daily'
     data = daily
    elsif m == 'weekly'
      data = weekly
    elsif m == 'monthly'
      data = monthly
    elsif m == 'yearly'
      data = yearly
    end
     render :json => data
  end
  
  
  def daily
    data = []
    chart_val_arr = []
    
    calories      = WebActivity.get_daily_calories(params[:userid])
    distance      = WebActivity.get_daily_ditance(params[:userid])
    steps         = WebActivity.get_daily_steps(params[:userid])
    chart_values  = WebActivity.get_daily_chart(params[:userid])
    most_active   = WebActivity.get_daily_most_active(params[:userid])
    
    if most_active.nil?
      most_act = "No active hour"
    else
      most_act = most_active['active_hour']
    end
    
    chart_values.each do |hour|
      chart_val_arr.push({label: hour.hour, value: hour.value})  
    end
    
    data.push({
      calories: calories["calories"] || 0, 
      distance: { value: distance['value'] || 0, unit: 'km' },
      steps: steps["steps"] || 0,   
      chart_values: chart_val_arr,
      most_active: most_act
    })

    return data
  end
  
  
  def weekly
    data      = []
    day_value = []
    @days     = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] 
     
    calories        = WebActivity.get_weekly_calories(params[:userid])
    distance        = WebActivity.get_weekly_distance(params[:userid])
    steps           = WebActivity.get_weekly_steps(params[:userid])
    chart_value     = WebActivity.get_weekly_chart(params[:userid])
    most_active_day = WebActivity.get_weekly_most_active_day(params[:userid])
    
    if most_active_day.nil?
      most_act = "No active hour"
    else
      most_act = most_active_day['day']
    end
    
    @days.each do |day|
      day_val = chart_value.select {|d| d['day'] == day}
      
      if day_val[0].nil?
         day_name = day
         day_runs = 0  
      else      
        day_name = day_val[0]['day']
        day_runs = day_val[0]['value'] 
      end
      
      day_value.push(label: day_name, value: day_runs)
    end
    
    data.push({
      calories: calories['calories'] || 0,
      distance: { value: distance['value'] || 0, unit: 'km'},
      steps: steps['steps'] || 0,
      chart_values: day_value,
      most_active: most_act
    })
    
    return  data
  end
  
  def catchNIL(data)
    return [] if data.nil?
    JSON.parse(data)  
  end

  def monthly
    data = []
    month_value = []
    @weeks = [1, 2, 3, 4, 5]
    @weeks_in_words = ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5']
    
    calories          = WebActivity.get_monthly_calories(params[:userid])
    distance          = WebActivity.get_monthly_distance(params[:userid])
    steps             = WebActivity.get_monthly_steps(params[:userid])
    chart_value       = WebActivity.get_monthly_chart(params[:userid])
    most_active_week  = WebActivity.get_monthly_most_active_week(params[:userid])
    
    unless most_active_week.nil?
      ma_week = "Week" + " " + most_active_week['week'].to_s
    else
      ma_week = "No active week"
    end
    
    @weeks.each_with_index  do |week,i|
      month_val = chart_value.select{ |d| d['week'] == week}
      
      if month_val[0].nil?
         month_name = week
         month_calories = 0  
      else
         month_name = month_val[0]['week']       
         month_calories = month_val[0]['value']
      end  
      month_value.push(label: @weeks_in_words[i], value:month_calories)
    end
    
    
    data.push({
      calories: calories['calories'] || 0,
      distance: distance['value'] || 0,
      steps: steps['steps'] || 0,
      chart_values: month_value,
      most_active: ma_week  
    })
    
    return data
  end
  
  def yearly
    data        = []
    year_value  = []
    date        = Time.now.strftime("%Y")                                                                  
    @months     = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']  
    
    calories          = WebActivity.get_yearly_calories(params[:userid])
    distance          = WebActivity.get_yearly_distance(params[:userid])
    steps             = WebActivity.get_yearly_steps(params[:userid])
    chart_value       = WebActivity.get_yearly_chart(params[:userid])
    most_active_month = WebActivity.get_yearly_most_active_month(params[:userid])
    
    if most_active_month.nil?
      most_act = "No active hour"
    else
      most_act = most_active_month['month']
    end
    
    @months.each do |month|
      year_val = chart_value.select{ |d| d['month'] == month}
      
      if year_val[0].nil?
         month_name = month
         month_runs = 0  
      else
         month_name = year_val[0]['month'] 
         month_runs = year_val[0]['value']
      end  
      year_value.push(label: month_name, value: month_runs)
    end
    
    data.push({
      calories: calories['calories'] || 0,
      distance: distance['value'] || 0,
      steps: steps['steps'] || 0,
      chart_values: year_value,
      most_active: most_act 
    })
        
    return data
  end
  
  def user_data
    data = [{
        leaderboard: leaderboard,
        points: points,
        badge: badges
      }]
      
     render :json => data  
  end
  
  def leaderboard
    @lb_player_arr    = []
    #ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c";
    json_object = JSON.parse(open(@@end_point + "/leaderboards/51154191297c01438f16f389.json?site=kreyos.nesventures.net").read)
    
    json_object['data']['positions'].map do |leaderboard|
        @lb_player_arr.push({
          player_name: WebUser.get_leaderboard_name(leaderboard['tx_leaderboard_position']['player_id']) || {name: "Unknown", uid: "none"},
          points: leaderboard['tx_leaderboard_position']['value'],
          rank: leaderboard['tx_leaderboard_position']['position'],
        })  
    end
   
    return @lb_player_arr
  end
  
  def points
    #ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c"
    user = WebUser.find_by_id(params[:userid])
    
    begin
      @points = JSON.parse(open(@@end_point + "/players/info.json?site=kreyos.nesventures.net&email=#{user['email']}").read)
      return @points['data']['points_all']
    rescue
      return 0
    end  
  end
  
  def badges
    data    = []
    page    = 1
    user    = WebUser.find_by_id(params[:userid])
    
    begin
      @badges = JSON.parse(open("#{@@end_point}/rewards.json?site=kreyos.nesventures.net&user=#{user['email']}&page=#{page}&per_page=50").read)
      
      @badges['data'].each do |badge|
        badge_name = badge['name']
        
        if badge_name.include?("Level")
           badge_level = "%02i" % badge['name'].split(" ")[1].to_i
           badge_name = "Level #{badge_level}"
        end
        
        data.push({
          name: badge_name,
          image: badge['image'],
          hint: badge['definition']['hint']
        })
      end
      
      page +=1
    end while @badges['data'] != []
    
    return data
  end
  
end