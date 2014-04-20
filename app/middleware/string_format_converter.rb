require 'sinatra/base'
require 'rack/request'
require 'rack/response'

class StringFormatConverter
  def initialize app
    @app = app # app 受け取る
  end

  def call env
    request = Rack::Request.new(env)
    @app.call(env)
  end
end