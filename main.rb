require 'soundcloud'
require 'json'
require 'optparse'
require_relative 'authenticate.rb'
client = authenticate()
me_hash = {}
page_size = 100 # reference: https://developers.soundcloud.com/docs#errors
sc_users = []
options = {}
optparse = OptionParser.new do |opts|
    opts.on("-F", "--followers", "Get followers for user") do
        options[:followers] = true
    end
    opts.on("-w","--web-profiles", "Get web profiles for user") do
        options[:web_profiles] = true
    end
    opts.on("-h","--help","Print help screen") do
        puts opts
        exit
    end
    opts.on("-v","--verbose","Print verbose output") do
        options[:verbose] = true
    end
    opts.on("-o FILE","--output","Write output to file") do |outputfile|
        options[:output] = outputfile
    end
    opts.on("-c COUNTRY","--country","List all users from the given country") do |country|
        options[:country] = country
    end
    opts.on("-C CITY","--city","List all users from the given city") do |city|
        options[:city] = city
    end
    opts.on("-u USER","--user","Get all data for a given user") do |user|
        options[:user] = user
    end
    opts.on("-m","--most-followers","Get user who has the most followers") do
        options[:most_followers] = true
    end
    opts.on("-l","--least-followers","Get user who has the least followers") do
        options[:least_followers] = true
    end
    opts.on("-G COUNT","--greater-than","Get user with a follower count greater than the given count") do |count|
        options[:greater_than] = count
    end
    opts.on("-L COUNT","--less-than","Get user with a follower count less than the given count") do |count|
        options[:less_than] = count
    end
end

optparse.parse!

client.get("/me").each { |k,v|
    me_hash[k] = v
}

followers = {}

class SoundCloudUser
    attr_accessor :username,
    :web_profiles,
    :id,
    :country,
    :web_profiles,
    :track_count,
    :followers_count,
    :followings_count,
    :public_favorites_count,
    :plan,
    :myspace_name,
    :discogs_name,
    :website_title,
    :website,
    :reposts_count,
    :comments_count,
    :online,
    :likes_count,
    :playlist_count,
    :avatar_url,
    :kind,
    :permalink_url,
    :uri,
    :permalink,
    :last_modified,
    :first_name,
    :last_name,
    :city,
    :description

    def initialize(
        username="",
        id="",
        web_profiles=[],
        country="",
        track_count=0,
        followers_count=0,
        followings_count=0,
        public_favorites_count=0,
        plan="",
        myspace_name="",
        discogs_name="",
        website_title="",
        website="",
        reposts_count=0,
        comments_count=0,
        online=false,
        likes_count=0,
        playlist_count=0,
        avatar_url=0,
        kind="",
        permalink_url="",
        uri="",
        permalink="",
        last_modified="",
        first_name="",
        last_name="",
        city="",
        description="")
    @username = username
    @country = country
    @track_count = track_count
    @followings_count = followings_count
    @public_favorites_count = public_favorites_count
    @plan = plan
    @myspace_name = myspace_name
    @discogs_name = discogs_name
    @website_title = website_title
    @website = website
    @reposts_count = reposts_count
    @comments_count = comments_count
    @online = online
    @likes_count = likes_count
    @playlist_count = playlist_count
    @avatar_url = avatar_url
    @kind = kind
    @permalink = permalink
    @last_modified = last_modified
    @first_name = first_name
    @last_name = last_name
    @city = city
    @description = description
    @web_profiles = web_profiles
    @id = id
    @followers_count = followers_count
end
end

def next_href(client,page_size,url,col,hrefs)
    if url != nil
        result = client.get(url, :limit => page_size, :linked_partitioning => 1)
        result.to_h!
        result.each {|k,v|
            if k == "next_href"
                next_href_url = v
                hrefs << next_href_url
                next_href(client,page_size,next_href_url,col,hrefs)
            elsif k == "collection"
                col << v
            end
        }
    end
end

def get_collection(client,url,page_size)
    client.get(url, :limit => page_size, :linked_partitioning => 1)
end

    # Takes a SoundCloud::HashResponseWrapper and turns it into a Hash we can iterate
    def schw_to_hash(schw)
        hash = {}
        schw.each {|schw_key,schw_value|
            schw_key.each {|key,val|
                hash[key] = val
            }
        }
        hash
    end

    if options[:verbose]
        puts "Collecting all users from followings..."
    end
    hrefs = []
    collections = []
    url = "/me/followings"
    next_href(client,page_size,url,collections,hrefs)
    users = []

    collections.each {|sch|
        my_hash = schw_to_hash(sch)
        my_hash.each {|k,v|
            if k == "username"
                users << v
            end
        }
    }
    hrefs.each {|h|
        if h != nil
            if options[:verbose]
                puts "URL: #{h}"
            end
            collection = get_collection(client,h,page_size)
            collection.delete_if {|key,value| key == "next_href" }
            collection.each {|k_1,v_1|
                v_1.each {|foo,bar|
                    collections << foo
                    sc_user = SoundCloudUser.new(
                        foo[:username],
                        foo[:id],
                        [],
                        foo[:country],
                        foo[:track_count],
                        foo[:followers_count],
                        foo[:followings_count],
                        foo[:public_favorites_count],
                        foo[:plan],
                        foo[:myspace_name],
                        foo[:discogs_name],
                        foo[:website_title],
                        foo[:website],
                        foo[:reposts_count],
                        foo[:comments_count],
                        foo[:online],
                        foo[:likes_count],
                        foo[:playlist_count],
                        foo[:avatar_url],
                        foo[:kind],
                        foo[:permalink_url],
                        foo[:uri],
                        foo[:permalink],
                        foo[:last_modified],
                        foo[:first_name],
                        foo[:last_name],
                        foo[:city],
                        foo[:description])
sc_users << sc_user
foo.each {|k_2,v_2|
    if k_2 == "username"
        username = v_2
        followers[username] = foo[:followers_count]
    end
}
}
}
if options[:verbose]
    puts "Getting next #{page_size} users..."
end
end
}

sorted_followers = followers.sort_by { |user,follower_count| follower_count}

if options[:followers]
    sorted_followers.each {|user,count|
        puts "#{user} (followers: #{count})"
    }
end

if options[:most_followers]
    puts "Getting user with the most followers:"
    most_followers = sorted_followers.last
    #p most_followers
    user = most_followers[0]
    count = most_followers[1]
    puts "#{user} (followers: #{count})"
end

if options[:least_followers]
    puts "Getting user with the least followers:"
    least_followers = sorted_followers.first
    #p least_followers
    user = least_followers[0]
    count = least_followers[1]
    puts "#{user} (followers: #{count})"
end

if options[:greater_than]
    gt_count = options[:greater_than].to_i
    puts "Getting users with more than #{gt_count} followers:"
    sorted_followers.each {|user,count|
        if count >= gt_count
            puts "#{user} (followers: #{count})"
        end
    }
end

if options[:less_than]
    lt_count = options[:less_than].to_i
    puts "Getting users with less than #{lt_count} followers:"
    sorted_followers.each {|user,count|
        if count <= lt_count
            puts "#{user} (followers: #{count})"
        end
    }
end

if options[:verbose]
    puts "Total users: #{sc_users.size}"
end

def web_profiles()
end

if options[:web_profiles]
    output = ""
    profile_count = 0
    if options[:output]
        output = options[:output]
        puts "Writing web profiles to #{output}..."
    end
    sc_users.each {|scuser|
        if scuser.id.nil?
            next
        end
        web_profiles_col = get_collection(client,"/users/#{scuser.id}/web-profiles",page_size)
        web_profiles_col.each {|web_key,web_val|
            web_val.each {|k1,v1|
                k1.each {|k2,v2|
                    if k2 == "url"
                        scuser.web_profiles << v2
                    end
                }
            }
        }
        if options[:output]
            if File.exist?(output)
                outfile = File.open(output,"a")
            else
                outfile = File.open(output,"w")
            end
        end
        unless scuser.web_profiles.empty?
            web_profiles = scuser.web_profiles
            web_profiles.each { |profile|
                if options[:output]
                    outfile.write("#{profile}\n")
                else
                    puts profile
                end
                profile_count += 1
            }
        end
        outfile.close
    }
    puts "Total web profiles: #{profile_count}"
end

if options[:country]
    country = options[:country]
    users = []
    puts "Getting all users from country #{country}:"
    sc_users.each {|scuser|
        if scuser.country
            if scuser.country.downcase == country.downcase
                users << scuser.username
                users.sort!
            end
        end
    }
    users.each {|user|
        puts user
    }
    puts "Total artists from #{country}: #{users.size}"
end

if options[:user]
    soundcloud_user = options[:user]
    puts "Getting data for #{soundcloud_user}..."
    sc_users.each {|scuser|
        if scuser.username.downcase == soundcloud_user.downcase
            user_data = <<USER_DATA
USERNAME: #{scuser.username}
Soundcloud ID: #{scuser.id}
URI: #{scuser.uri}
permalink: #{scuser.permalink}
permalink URL: #{scuser.permalink_url}
Country: #{scuser.country}
First Name: #{scuser.first_name}
Last Name: #{scuser.last_name}
Followers: #{scuser.followers_count}
Followings: #{scuser.followings_count}
Website: #{scuser.website}
Tracks: #{scuser.track_count}
Playlists: #{scuser.playlist_count}
Description: #{scuser.description}
USER_DATA
            puts user_data
            puts "Web Profiles:"
            scuser.web_profiles.each {|prof|
                puts prof
            }
        end
    }
end

