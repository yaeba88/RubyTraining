require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'sinatra/json'
require 'json'
require 'haml'
require 'redcarpet'

require_relative 'models/todo'

class Mosscow < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  set :static, true
  set :public_folder, 'public'
  set :views, File.dirname(__FILE__) + '/views'
  set :raise_errors, true
# set :show_exceptions, false # uncomment here when you do NOT want to see a backtrace
set :database_file, 'config/database.yml'

configure :development do
  register Sinatra::Reloader
end

before do
  ActiveRecord::Base.establish_connection(ENV['RACK_ENV'].to_sym)
  content_type 'text/html'
end

get '/problems' do
  haml :problems
end

get '/404' do
  halt 404
end

get '/500' do
  halt 500, haml(:internal_server_error)
end

get '/400' do
  halt 400, haml(:bad_request)
end

get '/error' do
  fail
end

get '/' do
  content_type 'text/plain'
  'Hello, Mosscow!'
end

get '/api/todos' do
  todos = Todo.all

  json todos.as_json
end

delete '/api/todos/:id' do
  todo = Todo.where(id: params[:id]).first
  response.status = 204
  todo.destroy
  nil
end

put '/api/todos/:id' do
  todo = Todo.where(id: params[:id]).first
  params = parse_request

  todo.is_done = params['is_done']
  todo.task_title = params['task_title']
  if todo.valid?
    todo.save!
    response.status = 200
    json todo.as_json
  else
    json_halt 400, todo.errors.messages
  end
end

post '/api/todos' do
  params = parse_request

  todo = Todo.new(task_title: params['task_title'],
    is_done: params['is_done'],
    order: params['order'])
  if todo.valid?
    todo.save!
    response.status = 201
    json todo.as_json
  else
    json_halt 400, todo.errors.messages
  end
end

after do
  ActiveRecord::Base.connection.close
end

helpers do
  Sinatra::JSON

  def json_halt(code, message)
    halt code, { 'Content-Type' => 'application/json' }, JSON.dump(message: message)
  end
  def parse_request
    begin
      return JSON.parse(request.body.read)
    rescue => e
      p e.backtrace unless ENV['RACK_ENV'] == 'test'
      json_halt 400, 'set valid JSON for request raw body.'
    end
  end
end

end
