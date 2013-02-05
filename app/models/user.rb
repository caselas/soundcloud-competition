class User < ActiveRecord::Base
  acts_as_voter
  has_many :tracks

  def self.identify_or_create_from_omniauth(auth)
    user_info = {
      uid: auth["uid"],
      name: auth["info"]["name"],
      username: auth["info"]["nickname"],
      permalink: auth["extra"]["raw_info"]["permalink_url"],
      avatar_url: auth["info"]["image"],
      city: auth["extra"]["raw_info"]["city"],
      country: auth["extra"]["raw_info"]["country"],
      token: auth["credentials"]["token"]
    }

    if user = User.find_by_uid(user_info[:uid])
      user.update_attributes!(user_info)
    else
      user = User.create(user_info)
    end

    user
  end

  def soundcloud
    Soundcloud.new(:client_id => Settings.key, :client_secret => Settings.secret, :access_token => token)
  end

  def soundcloud_tracks
    tracks = []
    eof = false    
    offset = 0

    until eof == true do    
      new_tracks = soundcloud.get("/me/tracks.json?offset=#{offset}")

      eof = true if new_tracks.length == 0

      for track in new_tracks
        if track.sharing == "public"
          tracks.push(track)
        end
      end

      offset += 50
    end

    tracks
  end

  def soundcloud_groups
    groups = soundcloud.get('/me/groups.json?limit=200')
    groups.delete_if { |g| g.creator.nil? || g.creator.id != uid }
  end

  def is_admin?(competition)
    competition.user.nil? || competition.user == self
  end
end
