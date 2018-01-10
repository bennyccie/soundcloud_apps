require 'soundcloud'
require 'json'

def authenticate
    begin
        f = File.open("credentials.json")
        json_creds = f.read
        f.close
        account = JSON.parse(json_creds)
        client = SoundCloud.new(
            :client_id => account['id'],
            :client_secret => account['secret'],
            :username => account['username'],
            :password => account['password']
            )
    rescue => e
        fail "ERROR: #{e.message}"
    end
    return client
end