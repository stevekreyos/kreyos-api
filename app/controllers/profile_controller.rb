class ProfileController < ApplicationController
  
  require 'open-uri'
  require 'json'

  include GeneralModule
  
  def profile
    #@@userid = params[:userid]
    data = [{
      points: total_points,
      info: user_info,
      member_since: member_since,
      lifetime_points: lifetime_points,
      recent_activities: recent_activities,
      badge: badges,
      daily_activity: daily_activity
    }]
    
    render :json => data
  end
  
  def fastest_mile
    @fastest_mile = WebActivity.get_fastest_mile(params[:unit], params[:member_id])
    return render :json => @fastest_mile
  end

  def longest_run
    @longest_run = WebActivity.get_longest_run(params[:unit], params[:member_id])
    return render :json => @longest_run
  end
  
  def recent_activities
    data    = []
    rewards = []
    page    = 1
    #ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c"
    user        = WebUser.find_by_id(params[:userid])
    
    begin
      @my_profile = JSON.parse(open(@@end_point + "/activities.json?site=kreyos.nesventures.net&user=#{user['email']}&page=#{page}&per_page=50").read)
      
      unless @my_profile['data'][0].nil?
        @my_profile['data'].each_with_index do |v, i|
          @my_profile['data'][i]['rewards'].each do |reward|
            
          reward_name = reward['name']
        
          if reward_name.include?("Level")
             badge_level = "%02i" % reward['name'].split(" ")[1].to_i
             reward_name = "Level #{badge_level}"
          end
              
          data.push({
              name: reward_name || "deleted",
              created_at: reward['created_at'],
              image: reward['image'] || "http://sandbox.v2.badgeville.com/images/misc/missing_badge.png",
          }).compact!
          end
        end
      end
      
      page += 1
      
    end while @my_profile['data'] != [] 
    
    return data
    
  end
  
  def member_since
    data = []
    user = WebUser.find_by_id(params[:userid])
    
    data.push({
      member_since: user['created_at'].strftime("%B %Y")
    })
    return data
  end
  
  def achiviements
    @achievements = WebActivities.get_total_run_and_hours()
  end
  
  def total_points
    #ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c"
    user = WebUser.find_by_id(params[:userid])
    
    begin
      @points = JSON.parse(open(@@end_point + "/players/info.json?site=kreyos.nesventures.net&email=#{user['email']}").read)
      return @points['data']['points_all']
    rescue
      return 0
    end  
  end
  
  def goals
    data = []
    @goals = WebGoal.where("member_id = ?", params[:userid])
    
    @goals.each do |goal|
      data.push({
        goal: goal['description'] || []
      })
    end
    
    return data
  end
  
  def kreyos_app_user
    your_friends = WebUser.get_friend_list(params[:userid])
    return your_friends
  end
  
  def user_info
    @info = WebUser.find_by_sql("SELECT wu.birthday, wu.gender, wui.city, wui.country FROM web_users AS wu INNER JOIN web_user_dimentions AS wui ON wu.id = wui.member_id WHERE wu.id = #{params[:userid]}")
    return @info
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
  
  def lifetime_points
    data = [
      WebActivity.find_by_sql("SELECT SUM(a_value) AS steps FROM web_activities WHERE member_id = #{params[:userid]} AND a_unit = 'steps'").first,
      WebActivity.find_by_sql("SELECT SUM(a_value) AS distance, a_unit AS unit FROM web_activities WHERE member_id = #{params[:userid]} AND a_unit = 'km'").first
     ]
    
    return data
  end
end