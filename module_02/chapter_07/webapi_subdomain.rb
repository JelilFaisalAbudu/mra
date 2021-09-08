# webapi_subdomain.rb
require 'sinatra'
require 'sinatra/subdomain'
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

# Contains the routes for the v1
subdomain :api1 do
  get '/users' do
    users.map { |name, data| data }.to_json
  end
end

# Contains all the routes for the v2
subdomain :api2 do
  get '/users' do
    users.map do |name, data|
      {
        full_name: "#{data[:first_name]} #{data[:last_name]}",
        age: data[:age]
      }
    end.to_s
  end
end