module GeneralModule
  
  require "digest/md5"
  
  @@domain = 'kreyos.nesventures.net'
  @@url_domain = 'http://kreyos.nesventures.net'
  @@end_point = 'http://sandbox.v2.badgeville.com/api/berlin/dac05af7b1940f5f12b88de191a0734c'
  
  def setup_email
    @email = WebSetup.email()
    @password = WebSetup.password()
    @host = WebSetup.host()
    @port = WebSetup.port()
    @ssl = WebSetup.ssl()
    @username = @email[0]['value'].split('@')[0]

    ActionMailer::Base.smtp_settings = {
      :address              => @host[0]['value'],
      :port                 => @port[0]['value'],
      :domain               => @@domain,
      :user_name            => @username,
      :password             => @password[0]['value'],
      :authentication       => "plain",
      :enable_starttls_auto => true
    }
    
    ActionMailer::Base.default_url_options[:host] = @@domain
  end
  
  def render_json(data, status=200)
    return render :json => data, :status => status
  end
  
  def recent_activity_get_name(*args)
    @player_name_array = []
    
    args.each do |id|
      player_name = WebUser.find_by_bv_id(id)
        if player_name.nil?
          @player_name_array.push({name:"Unknown"})
        else
          @player_name_array.push({name:player_name.name})
        end
    end
    
    return @player_name_array
  end
  
  def leaderboard_get_name(*args)
    @player_name_array = []
    
    args.each do |id|
      player_name = WebUser.find_by_bv_player_id(id)
        if player_name.nil?
          @player_name_array.push({name:"Unknown"})
        else
          @player_name_array.push({name:player_name.name})
        end
    end
    
    return @player_name_array
  end
  
  def check_pending_friends(userid, bv_player_id, email)
    # => Get pending friends
    friends = WebFriend.get_pending_friends(userid)
    @friends_email = ""
    
    unless friends.length == 0
      friends.each do |friend|
        @friends_email += "'#{friend[:invitee_email]}',"
      end
      @friend_player_bv_id = WebUser.get_friends_player_bv_id(@friends_email.chomp(','))
      
      # => Update status and badgeviller player id
      @friend_player_bv_id.each do |bpi|
        @update_bv_player_id = WebFriend.update_player_bv_id(userid, bpi[:email], bpi[:bv_player_id].to_s)
      end
    end
    
    # => Check for your pending friends
      become_friends = WebFriend.where(:invitee_email => email)
      
      become_friends.each do |bf|
        become_friends_info = WebUser.find_by_id(bf['member_id'])
        add_bf = WebFriend.find_by_member_id_and_invitee_email(userid, become_friends_info['email']) || WebFriend.add_as_friend(userid, bv_player_id,  become_friends_info['email'], become_friends_info['bv_player_id'])
      end
    # => END Check for your pending friends
  end
end