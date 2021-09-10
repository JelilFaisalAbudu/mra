# webapi_versioning_in_accept_header_with_version_option.rb
# In this type of versioning the version is part of the accept header as an option.
# Although we could simply use application/json, using a
# custom media type allows us to explain the format in detail in our
# documentation.

require 'sinatra'
require 'gyoku'
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

# V1 returns the data as it is from db
v1_lambda = lambda { |name, data| data.merge(id: name) }
# v2 returns the data with changes to the resource representation.
# Some attribute will be removed/added.
v2_lambda = lambda do |name, data|
  {
    full_name: "#{data[:first_name]} #{data[:last_name]}",
    age: data[:age],
    id: name
  }
end


# media type(s) to support.
# For now it's one. However you create a list of the media types and
# iterate through the list to assign the various versions.
supported_media_types = {
  'application/vnd.awesomeapi+json' => {
    '1' => v1_lambda,
    '2' => v2_lambda
  },
}

media_types = [
  'application/vnd.awesomeapi+json',
  'application/vnd.awesomeapi+xml',
]

helpers do
  def unsupported_media_type!(supported_media_types)
    content_type 'application/vnd.awesomeapi.error+json'
    error_message = supported_media_types.each_with_object([]) do |(mt, versions), arr|
      arr << {
        supported_media_type: mt,
        supported_versions: versions.keys.join(', '),
        format: "Accept: #{mt}; version={version}"
      }
    end
    halt 406, error_message.to_json
  end
end

before do
  @request_media_type = request.accept.first
  @request_media_type_str = @request_media_type.to_s
  @request_version = @request_media_type.params['version'] || '1'
end

get '/users' do
  unless supported_media_types[@request_media_type_str] &&
     supported_media_types[@request_media_type_str][@request_version]
    unsupported_media_type!(supported_media_types)
  end

  content_type "#{@request_media_type}; version=#{@request_version}"
  users.map(&supported_media_types[@request_media_type_str][@request_version]).to_json
end
