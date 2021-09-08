# webapi_parameter.rb
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

helpers do
  def present_300
    {
      message: 'Multiple versions available (?version=)',
      links: {
        v1: '/users?version=v1',
        v2: '/users?version=v2'
      }
    }
  end

  def present_v2(data)
    {
      full_name: "#{data[:first_name]} #{data[:last_name]}",
      age: data[:age]
    }
  end
end

get '/users' do
  versions = {
    'v1' => lambda { |name, data| data },
    'v2' => lambda { |name, data| present_v2(data) }
  }

  unless params[:version] && versions.keys.include?(params[:version])
    halt 300, present_300.to_json
  end

  users.map(&versions[params['version']]).to_json
end