# Returns tracks of a certain genre created in the last week

require 'json'
require 'date'

client_id = ENV['SOUNDCLOUD_CLIENT_ID']
limit = 20

genres = %W(
	dubstep
	trance
	house
	techno
	trap
	drumbass
	electronic
	deephouse
	danceedm
)
if client_id.nil?
	puts "ERROR: You must export SOUNDCLOUD_CLIENT_ID in your environment"
	exit(1)
else
	track_list = "/tmp/tracks.html"
	f = File.open(track_list,"w")
	f.write("Last Updated: #{Date.today}")
	genres.each {|genre|
		f.write("<h1><u>#{genre}<u></h1>")
		f.write("<ul>")
		tracks_array = []
		puts "Getting newest #{limit} tracks of genre: #{genre}"
		tracks_json = %x(curl -s "https://api-v2.soundcloud.com/charts?kind=trending&genre=soundcloud%3Agenres%3A#{genre}&client_id=#{client_id}&limit=#{limit}&offset=0")
		tracks = JSON.parse(tracks_json)
		collection = tracks['collection']
		collection.each {|track|
			track_hash = track['track']
			date = track_hash['created_at']
			a_week_ago = (Date.today - 7)
			new_date = Date.parse(date)
			if new_date <= Date.today and new_date >= a_week_ago
				title = track_hash['title']
				url = track_hash['permalink_url']
				genre_tag = track_hash['genre']
				tracks_array << %Q(<a href="#{url}">#{title}</a> (tag: #{genre_tag}))

			end
		}
		tracks_array.uniq!
		tracks_array.each {|track_info|
			f.write("<li>#{track_info}</li>")
		}
		f.write("</ul>")
	}
	puts "Done writing tracks to: #{track_list}"
	f.close

end

