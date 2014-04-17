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
      r.status = 500
      r["Content-Type"] = "application/json"
      r.write JSON.dump(message: 'unexpected error')
    }
  end
end