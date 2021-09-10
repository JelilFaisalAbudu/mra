# weapi_versioning_media-type
# Determines the media type from the request.accept header
# to send the resource representation to the client
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


def present_v2(data)
  {
    full_name: "#{data[:first_name]} #{data[:last_name]}",
    age: data[:age]
  }
end

# Specifies the resource kind to send based on the media
v1_lambda = lambda { |name, data| data }
v2_lambda = lambda { |name, data| present_v2(data).merge(id: name) }


supported_media_types = {
  '*/*' => v1_lambda,
  'application/*' => v1_lambda,
  'application/vnd.awesomeapi+json' => v1_lambda,
  'application/vnd.awesomeapi.v1+json' => v1_lambda,
  'application/vnd.awesomeapi.v2+json' => v2_lambda
}


get '/users' do
  accepted_media_type = request.accept.first ? request.accept.first.to_s : '*/*'

  unless supported_media_types.keys.include?(accepted_media_type)
    content_type 'application/vnd.awesomeapi.error+json'
    message = {
      supported_media_types: supported_media_types.keys.join(', ')
    }.to_json

    halt 406, message
  end

  content_type accepted_media_type
  users.map(&supported_media_types[accepted_media_type]).to_json
end


