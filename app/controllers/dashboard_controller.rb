class DashboardController < ApplicationController
  require 'open-uri'
  require 'json'
    
  include GeneralModule
  
  def show_all
     data = [{
        leaderboard: leaderboard,
        recent_activity: recent_activities,
        daily_activity: daily_activity,
        weekly_activity: weekly_activity,
        monthly_activity: monthly_activity,
        yearly_activity: yearly_activity,
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
  
  def recent_activities
    @res_arr    = []
    page        = 1
    friends_pid = WebFriend.find_all_by_member_id_and_status(params[:userid], 1)
    
    begin
      json_object = JSON.parse(open(@@end_point + "/activities.json?site=kreyos.nesventures.net&page=#{page}&per_page=50").read)
      
      friends_pid.each do |fpid|
        @bv_activities = json_object['data'].select { |d| d['player_id'] == fpid['invitee_bv_player_id'] }

         @bv_activities.map do |data|
           data['rewards'].map do |subdata|
             @res_arr.push({
                name: subdata['name'],
                type: subdata['definition']['type'],
                created_at: Date.parse(subdata['created_at']).strftime("%b %d, %Y"),
                player_name: WebUser.g_name(subdata['user_id']) || {name: "Unknown", uid: "none"}
              }).compact!
           end
         end 
      end
      
      page += 1
      
    end while json_object['data'] != []
    
    return @res_arr
  end
  
  def check_goal_expiration
    goal_stat = WebGoal.check_if_expired(params[:userid])
    
    if goal_stat['status'] == -1
      WebGoal.goal_change_status(params[:userid])    
    end
    
    render :json => goal_stat
  end
  
  def daily_activity
    data = []
    chart_val_arr = []
    chart_val_arr_steps = []
    chart_val_arr_km    = []

    
    calories      = WebActivity.get_daily_calories(params[:userid])
    distance      = WebActivity.get_daily_ditance(params[:userid])
    steps         = WebActivity.get_daily_steps(params[:userid])
    chart_values  = WebActivity.get_dashboard_calories_chart(params[:userid])
    chart_values_steps  = WebActivity.get_dashboard_steps_chart(params[:userid])
    chart_values_km     = WebActivity.get_dashboard_km_chart(params[:userid])
    most_active   = WebActivity.get_daily_most_active(params[:userid])
    goals         = WebGoal.get_user_goals(params[:userid])
    gp_steps      = steps['steps'] || 0
    gp_distance   = distance['value'] || 0 
    gp_calories   = calories['calories'] || 0

    chart_values.each do |hour|
      chart_val_arr.push({label: hour.hour, value: hour.value})  
    end
    
    chart_values_steps.each do |hour|
      chart_val_arr_steps.push({hour: hour.hour, value: hour.value})  
    end
    
    chart_values_km.each do |hour|
      chart_val_arr_km.push({hour: hour.hour, value: hour.value})  
    end
   
   unless goals.nil?
      data.push({
        calories: calories["calories"] || 0, 
        distance: { value: distance['value'] || 0, unit: 'km' },
        steps: steps["steps"] || 0,
        goals: { 
          steps: goals['steps'],
          kilometers: goals['kilometers'],
          calories: goals['calories']
        },
        goals_percentage: {
          steps: (gp_steps * 100) / goals['steps'],
          kilometers: (gp_distance * 100) / goals['kilometers'],
          calories: (gp_calories * 100) / goals['calories']
        },
        chart_values: [{
          calories: chart_val_arr,
          steps: chart_val_arr_steps,
          km: chart_val_arr_km
        }],
      })
    else
      data.push({
        calories: calories["calories"] || 0, 
        distance: { value: distance['value'] || 0, unit: 'km' },
        steps: steps["steps"] || 0,
        goals: [],
        goals_percentage: [],
        chart_values: [{
          calories: chart_val_arr,
          steps: chart_val_arr_steps,
          km: chart_val_arr_km
        }],
      })
    end

    return data
  end
  
  def weekly_activity
    data      = []
    day_value = []
     
    calories = WebActivity.get_weekly_calories(params[:userid])
    distance = WebActivity.get_weekly_distance(params[:userid])
    steps    = WebActivity.get_weekly_steps(params[:userid])
    goals    = WebGoal.get_user_goals(params[:userid])
    
    gp_steps      = steps['steps'] || 0
    gp_distance   = distance['value'] || 0 
    gp_calories   = calories['calories'] || 0
    
    unless goals.nil?
      total_steps   = goals['steps'] * 7 || 0
      total_dist    = goals['kilometers'] * 7 || 0
      total_cal     = goals['calories'] * 7 || 0
      
      data.push({
        calories: calories['calories'] || 0,
        distance: { value: distance['value'] || 0, unit: 'km'},
        steps: steps['steps'] || 0,
        goals: { 
          steps: total_steps,
          kilometers: total_dist,
          calories: total_cal
        },
        goals_percentage: {
          steps: (gp_steps * 100) / total_steps,
          kilometers: (gp_distance * 100) / total_dist,
          calories: (gp_calories * 100) / total_cal
        }
      })
    else
      data.push({
        calories: calories['calories'] || 0,
        distance: { value: distance['value'] || 0, unit: 'km'},
        steps: steps['steps'] || 0,
        goals: [],
        goals_percentage: []
      })  
    end
    
    return  data
  end
  
  def monthly_activity
    data        = []
    month_value = []
    
    calories    = WebActivity.get_monthly_calories(params[:userid])
    distance    = WebActivity.get_monthly_distance(params[:userid])
    steps       = WebActivity.get_monthly_steps(params[:userid])
    goals       = WebGoal.get_user_goals(params[:userid])
    
    gp_steps    = steps['steps'] || 0
    gp_distance = distance['value'] || 0 
    gp_calories = calories['calories'] || 0
    
    
    unless goals.nil?
      total_steps   = goals['steps'] * 30 || 0
      total_dist    = goals['kilometers'] * 30 || 0
      total_cal     = goals['calories'] * 30 || 0
      
      data.push({
        calories: calories['calories'] || 0,
        distance: { value: distance['value'] || 0, unit: "km" },
        steps: steps['steps'] || 0,
        goals: { 
          steps: total_steps,
          kilometers: total_dist,
          calories: total_cal
        },
        goals_percentage: {
          steps: (gp_steps * 100) / total_steps,
          kilometers: (gp_distance * 100) / total_dist,
          calories: (gp_calories * 100) / total_cal
        }
      })
    else
      data.push({
      calories: calories['calories'] || 0,
      distance: { value: distance['value'] || 0, unit: "km" },
      steps: steps['steps'] || 0,
      goals: [],
      goals_percentage: []
    })
    end
    
    return data
  end
  
  def yearly_activity
    data       = []
    year_value = []
    
    calories = WebActivity.get_yearly_calories(params[:userid])
    distance = WebActivity.get_yearly_distance(params[:userid])
    steps    = WebActivity.get_yearly_steps(params[:userid])
    goals    = WebGoal.get_user_goals(params[:userid])
    
    gp_steps      = steps['steps'] || 0
    gp_distance   = distance['value'] || 0 
    gp_calories   = calories['calories'] || 0
    
    unless goals.nil?
      total_steps   = goals['steps'] * 365 || 0
      total_dist    = goals['kilometers'] * 365 || 0
      total_cal     = goals['calories'] * 365 || 0
      
      data.push({
        calories: calories['calories'] || 0,
        distance: { value: distance['value'] || 0, unit: "km" },
        steps: steps['steps'] || 0,
        goals: { 
          steps: total_steps,
          kilometers: total_dist,
          calories: total_cal
        },
        goals_percentage: {
          steps: (gp_steps * 100) / total_steps,
          kilometers: (gp_distance * 100) / total_dist,
          calories: (gp_calories * 100) / total_cal
        }
      })
    else
      data.push({
        calories: calories['calories'] || 0,
        distance: { value: distance['value'] || 0, unit: "km" },
        steps: steps['steps'] || 0,
        goals: [],
        goals_percentage: []
      })  
    end
        
    return data
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
  
  def save_goals
    goals = WebGoal.set_new_goal(params[:userid], params[:description], params[:calories], params[:distance], params[:steps], params[:expires])
    render :json => goals 
  end
  
  def goal_info
    goal = WebGoal.find_by_member_id_and_status(params[:userid], 1)
    render :json => goal
  end
  
  def save_edit_goals
    edit_goal = WebGoal.edit_goal(params[:userid], params[:description], params[:calories], params[:distance], params[:steps], params[:expires])
    render :json => edit_goal
  end
  
  def delete_goal
    delete_goal = WebGoal.del_goal(params[:goalID])
    render :json => delete_goal
  end
end