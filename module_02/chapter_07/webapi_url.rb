# webapi_url
require 'sinatra'
require 'sinatra/contrib'
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

namespace '/v1' do
  get '/users' do
    users.map { |name, data| data }.to_json
  end
end

namespace '/v2' do
  get '/users' do
    users.map do |name, data|
      {
        full_name: "#{data[:first_name]} #{data[:last_name]}",
        age: data[:age]
      }
    end.to_json
  end
end