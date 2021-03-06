# web_api.rb

require 'sinatra'
require 'json'
require 'gyoku'
# require_relative './users'

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
  def json_or_default?(type)
    %w(application/json application/* */*).include?(type.to_s)
  end

  def xml?(type)
    type.to_s == 'application/xml'
  end

  def accepted_media_type
    return 'json' unless request.accept.any?
  
    request.accept.each do |mt|
      return 'json' if json_or_default?(mt)
      return 'xml' if xml?(mt)
    end
    
    content_type 'text/plain'
    halt 406, 'Not Acceptable. Accepts only application/json, application/xml'
  end

  def type
    @type ||= accepted_media_type
  end

  def send_data(data = {})
    if type == 'json'
      content_type 'application/json'
      data[:json].call.to_json if data[:json]
    elsif type == 'xml'
      content_type 'application/xml'
      Gyoku.xml(data[:xml].call) if data[:xml]
    end
    
  end

  def check_bad_request
    begin
      JSON.parse(request.body.read)
      rescue JSON::ParserError => e
        halt 400, send_data(json: -> { { message: e.to_s } },
                            xml: -> { { message: e.to_s } })
    end
  end

  def check_media_type_request
    halt 415 unless request.env['CONTENT_TYPE'] == 'application/json'
  end
  
end



get '/' do
  'Master Ruby Web APIs - Chapter 2'
end

options '/users' do
  response.headers['Allow'] = 'HEAD, GET, POST'
  status 200
end

head '/users' do
  send_data
end

get '/users' do
  send_data(
    json: -> { users.map { |name, data| data.merge(id: name)} },
    xml: -> { {users: users} }
  )
end

get '/users/:first_name' do |first_name|
  user = users[first_name.to_sym]
  halt 404 unless user

  send_data(
    json: -> { user.merge(id: first_name) },
    xml: -> { { user: user } }
  )
end

options '/users/:first_name' do
  response.headers['Allow'] = 'GET, PUT PATCH, DELETE'
  status 200
end

post '/users' do
  check_media_type_request
  check_bad_request

  if users[user['first_name'].downcase.to_sym]
    message = { message: "User #{user['first_name']} already exist in the DB." }
    halt 409, send_data(json: -> { message },
                        xml: -> { message })
  end
  users[user['first_name'].downcase.to_sym] = user

  url = "http://localhost:4567/users/user/#{user[:first_name]}"
  response.headers['Location'] = url

  status 201
end

put '/users/:first_name' do |first_name|
  check_media_type_request
  check_bad_request

  user = JSON.parse(request.body.read)
  existing = users[first_name.to_sym]
  users[first_name.to_sym] = user

  status existing ? 204 : 201
end

patch '/users/:first_name' do |first_name|
  check_media_type_request
  check_bad_request

  user = users[first_name.to_sym]

  halt 404 unless user

  client_data = JSON.parse(request.body.read)
  media_type = accepted_media_type

  client_data.each do |key, value|
    user[key.to_sym] = value
  end

  send_data(
    json: -> { user.merge(id: first_name) },
    xml: -> { { user: user } }
  )
end

delete '/users/:first_name' do |first_name|
  return 404 unless users[first_name.to_sym]
  users.delete(first_name.to_sym)
  status 204
end

[:put, :delete, :patch].each do |method|
  send(method, '/users') do
    halt 405, 'Method Not Allowed. Use GET, HEAD, or OPTIONS'
  end
end
