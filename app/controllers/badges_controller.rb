class BadgesController < ApplicationController

  require 'open-uri'
  require 'json'
  
  include GeneralModule
  
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
    
    render :json => data
  end

end