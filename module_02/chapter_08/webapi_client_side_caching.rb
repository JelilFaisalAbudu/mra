# webapi_caching.rb

# => Client Caching <= Allowing client to cache the response
# Include Cache-Control header with the max-age directive and the ETag  header.
# Sinatra has helper methods for each scenarios. You just pass the value to the appropriate method.

require 'sinatra'
require 'json'
require 'digest/sha1'

users = {
  jelil: {
    first_name: 'Jelil',
    last_name: 'Abudu',
    age: 30
  },
  denis: {
    first_name: 'Denis',
    last_name: 'Alonzo',
    age: 23
  },
  bryan: {
    first_name: 'Bryan',
    last_name: 'Anderson',
    age: 25
  },
  jane: {
    first_name: 'Jane',
    last_name: 'Doe',
    age: 24
  },
}

before do
  content_type 'application/json'

  # Adding the Cache-Control header with the max-age directive.
  cache_control max_age: 60
end

get '/users' do
  # Using the etag method, giving the digest of the users hash(converted to string before)
  etag Digest::SHA1.hexdigest users.to_s
  users.map{ |name, data| data.merge(id: name) }.to_json
end