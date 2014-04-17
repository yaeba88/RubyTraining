require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/reloader'
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
    hundle_error
  end

  get '/' do
    content_type 'text/plain'
    'Hello, Mosscow!'
  end

  get '/api/todos' do
    todos = Todo.all

    content_type :json
    JSON.dump(todos.as_json)
  end

  delete '/api/todos/:id' do
    todo = Todo.where(id: params[:id]).first
    hundle_error {todo.destroy}
    response.status = 204
    nil
  end

  put '/api/todos/:id' do
    todo = Todo.where(id: params[:id]).first

    begin
      params = JSON.parse(request.body.read)
    rescue => e
      p e.backtrace unless ENV['RACK_ENV'] == 'test'
      halt 400, { 'Content-Type' => 'application/json' }, JSON.dump(message: 'set valid JSON for request raw body.')
    end

    todo.is_done = params['is_done']
    todo.task_title = params['task_title']
    if todo.valid?
      todo.save!
      response.status = 200
      content_type :json
      JSON.dump(todo.as_json)
    else
      halt 400, { 'Content-Type' => 'application/json' }, JSON.dump(message: todo.errors.messages)
    end
  end

  post '/api/todos' do
    begin
      params = JSON.parse(request.body.read)
    rescue => e
      p e.backtrace unless ENV['RACK_ENV'] == 'test'
      halt 400, { 'Content-Type' => 'application/json' }, JSON.dump(message: 'set valid JSON for request raw body.')
    end

    todo = Todo.new(task_title: params['task_title'],
                    is_done: params['is_done'],
                    order: params['order'])
    if todo.valid?
      todo.save!
      response.status = 201
      content_type :json
      JSON.dump(todo.as_json)
    else
      halt 400, { 'Content-Type' => 'application/json' }, JSON.dump(message: todo.errors.messages)
    end
  end

  after do
    ActiveRecord::Base.connection.close
  end

  helpers do
    def hundle_error
      begin
        yield
      rescue
        halt 500, { 'Content-Type' => 'application/json' }, JSON.dump(message: 'unexpected error')
      end
    end
  end
end
