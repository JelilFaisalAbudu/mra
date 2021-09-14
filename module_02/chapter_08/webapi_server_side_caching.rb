# webapi_server_side_caching.rb
# Here, we use custom a method, #cache_and-return to do caching.
# This is because, unlike Rails, Sinatra does not have the "updated_at" attribute for each entity in DB, we would include a key in the entity.
# Also, we don't currently memcache or redis installed, so we are just using a Ruby hash

require 'sinatra'
require 'json'
require 'digest/sha1'

users = {
  revision: 1, #NB: It's supposed to be for each user in the :list key
  list: {

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
}

cached_data= {};

helpers do
  def cache_and_return(cached_data, key, &block)
    cached_data ||= block.call
    cached_data[key]
  end
end

before do
  content_type 'application/json'
end

get '/users' do
  key = "users:#{users[:revision]}"
  
  cache_and_return(cached_data, key) do
    # Create a huge json representation for the resource for our get response.
    (1..1000).each_with_object([]) do |index, array|
      users[:list].each do |name, data|
        array << data
      end
    end.to_json
  end
end

put '/users/:first_name' do
  user_params = JSON.parse(request.body.read)
  existing = users[:list][:first_name]
  
  return status 204 unless existing
  users[:revision] += 1 # update the revision
  users[:list][:first_name] = user_params
  status 201
end