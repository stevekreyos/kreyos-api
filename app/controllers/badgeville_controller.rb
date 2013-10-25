class BadgevilleController < ApplicationController
  
  require 'open-uri'
  require 'json'
  require 'net/http'
  require 'uri'
  
  include GeneralModule
  
  def show_all_users
    ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c";
    
    json_object = JSON.parse(open(ep + "/users.json").read)
    render :json => json_object
  end
  
  def show_all_activities
    ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c";
    
    json_object = JSON.parse(open(ep + "/activities.json").read)
    render :json => json_object
  end
  
  
  def show_all_leaderboards
    ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c";
    
    #json_object = JSON.parse(open(ep + "/leaderboards.json").read)
    json_object = JSON.parse(open(ep + "/leaderboards/51154191297c01438f16f387.json?site=kreyos.nesventures.net").read)
    render :json => json_object
  end
  
  def show_all_rewards
    ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c";
    
    json_object = JSON.parse(open(ep + "/rewards.json").read)
    render :json => json_object
  end
  
  
  def show_all_reward_definitions
    ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c";
    
    json_object = JSON.parse(open(ep + "/reward_definitions.json").read)
    render :json => json_object
  end
  
  def show_all_levels
    ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c";
    
    json_object = JSON.parse(open(ep + "/levels.json").read)
    render :json => json_object
  end
  
  def show_all_teams
    ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c";
    
    json_object = JSON.parse(open(ep + "/teams.json").read)
    render :json => json_object
  end
  
  def show_all_players
    ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c";
    
    json_object = JSON.parse(open(ep + "/players.json").read)
    render :json => json_object
  end
  
  def show_player_by_email
    ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c";
    
    json_object = JSON.parse(open(ep + "/players.json?kreyos.nesventures.net&email=" + params[:email]).read)
    render :json => json_object
  end
  
  def activities_by_user
    
    ep = "http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c";
    
    json_object = JSON.parse(open(ep + "/activities.json?site=kreyos.nesventures.net&user=user10@badgeville.com").read)
    #json_object = JSON.parse(open("http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c/activities.json?site=kreyos.nesventures.net&page=1").read)
    render :json => json_object
  end
  
  def rewards
    ep = "#{@@end_point}/activities.json"
    user = WebUser.find_by_id(params[:userid])
    type = params[:type]
    
    if type == 'pfe'
      v = "per_feet_elevation"
    elsif type == 'es'
      v = "every_step"
    elsif type == 'at'
      v = "every_hour_of_active_time"
    elsif type == 'share'
      v = "share"
    elsif type == 'sync'
      v = "sync"
    end
    
    url = URI.parse(ep)
    reg_response = Net::HTTP.post_form(url, {"site" =>"kreyos.nesventures.net", "user" => user['email'], "activity[verb]" => "#{v}"})
    json_obj = JSON.parse(reg_response.body)
    render :json => json_obj
  end
  
  def infusionsoft
    user = Infusionsoft.contact_add({:FirstName => 'Juan', :LastName => 'Dela Cruz', :Email => 'juandelacruz@yahoo.com'})
    render :json => user
  end
  

end