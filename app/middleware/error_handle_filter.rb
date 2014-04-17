require 'rack/request'
require 'rack/response'

class ErrorHandleFilter
  def initialize app
    @app = app
  end

  def call env
    @app.call(env)
  rescue
    response = Rack::Response.new {|r|
      r.status = 400
      r["Content-Type"] = "text/html"
      r.write "Bad Request"
    }
  end
end