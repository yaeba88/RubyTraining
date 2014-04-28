require 'sinatra/base'
require 'rack/request'
require 'rack/response'

class StringFormatConverter
  def initialize app
    @app = app # app 受け取る
  end

  def call(env)

    if env['CONTENT_TYPE'] == 'application/json'
      input = env['rack.input'].read
      json = JSON.parse(input)

      fixed_request_input = change_json_key_to_snake(json).to_json
      env['rack.input'] = StringIO.new(fixed_request_input)
      puts "[REQUEST]fixed_request_input: " + fixed_request_input
    end

    response = @app.call(env)

    response_header = response[1]
    response_body   = response[2]
    # json = JSON.parse(response_body)
    # json = JSON.parse(response_body[0])
    puts "[RESPONSE]original_response:" + response.to_s

    if response_header['Content-Type'] =~ /application\/json/
      fixed_response_body = Array.new
      fixed_response_body[0] = change_json_key_to_camel(JSON.parse(response_body[0])).to_json
      response[2] = fixed_response_body
      response[1]['Content-Length'] = fixed_response_body.reduce(0){ |s, i| s + i.bytesize }.to_s
      puts "[RESPONSE]fixed_response:" + response.to_s
    end
    response
  end

  # refer to http://qiita.com/labocho/items/9e374de17675cb6114af
  def change_json_key_to_snake(json)
    case json
    when Array
      json.map{|e| change_json_key_to_snake(e)}
      return json
    when Hash
      hash = {}
      json.each do |(k, v)|
        hash[k.to_snake] = change_json_key_to_snake(v)
      end
      return hash
    else
      return json
    end
  end

  def change_json_key_to_camel(json)
    case json
    when Array
      json.map!{|e| change_json_key_to_camel(e)}
      return json
    when Hash
      hash = {}
      json.each do |(k, v)|
        hash[k.to_camel] = change_json_key_to_camel(v)
      end
      return hash
    else
      return json
    end
  end
end