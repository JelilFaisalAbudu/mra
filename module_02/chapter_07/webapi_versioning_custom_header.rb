# webapi_versioning_custom_header.rb
# NOTE: There is a problem with caching with this approach.

require 'sinatra'
require 'json'

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
end

helpers do
  def present_v2(data)
    {
      full_name: "#{data[:first_name]} #{data[:last_name]}",
      age: data[:age],
    }
  end
end

get '/users' do
  client_version = request.env['HTTP_VERSION'].split(',')[-1]
  if client_version.to_s.strip == '2.0'
    halt 200, users.map { |name, data| present_v2(data) }.to_json
  end
  users.map { |name, data| data }.to_json
end
