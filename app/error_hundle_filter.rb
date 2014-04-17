require 'rack/request'
require 'rack/response'

class APIRequestFilter
  def initialize app
    @app = app
  end

  def call env
    request = Rack::Request.new(env)
    raise unless request.content_type == 'application/json'
    @app.call(env)
  rescue
    response = Rack::Response.new {|r|
      r.status = 400
      r["Content-Type"] = "text/html"
      r.write "Bad Request"
    }
    response.finish
  end
end