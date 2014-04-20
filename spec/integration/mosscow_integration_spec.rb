require 'error_handle_filter'

require_relative '../../app/string_expansion'

describe 'Integration Test' do
  let(:snake_expected){ { 'is_done' => true, 'order' => 1, 'task_title' => 'hoge' } }
  let(:camel_expected){ { 'isDone'  => true, 'order' => 1, 'taskTitle'  => 'hoge' } }

  def post_todo(body)
    post '/api/todos', JSON.dump(body), 'CONTENT_TYPE' => 'application/json'
  end

  before do
    post_todo(camel_expected)
  end

  include Rack::Test::Methods

  def app
    @app ||= ErrorHandleFilter.new(Mosscow)
  end

  # Please delete 'broken:true' after you create Rack camel <-> snake converting middleware
  context 'when api called' do
    context 'GET /api/todos' do
      it 'returns 200' do
        get '/api/todos'
        expect(last_response.status).to eq 200
        JSON.parse(last_response.body).each do |todo|
          expect(todo['isDone']).to_not be_nil
          expect(todo['taskTitle']).to_not be_nil
        end
      end
    end

    context 'POST /api/todos' do
      it 'returns 201' do
        post_todo(camel_expected)

        expect(last_response.status).to eq 201
        expect(JSON.parse(last_response.body)).to include camel_expected
      end
    end

    context 'PUT /api/todos/:id' do
      let(:updated){ { 'isDone' => false, 'order' => 1, 'taskTitle' => 'moge' } }
      it 'returns 204' do
        put '/api/todos/1', JSON.dump(updated), 'CONTENT_TYPE' => 'application/json'

        expect(JSON.parse(last_response.body)).to include updated
      end
    end

    context 'DELETE /api/todos' do
      it 'returns 204' do
        post_todo(camel_expected)

        delete '/api/todos/2'
        expect(last_response.status).to eq 204
      end
    end
  end

  context 'For Rack error catching modules' do
    let(:expected){ { 'message' => 'unexpected error' } }

    context 'GET /error' do
      it 'returns 500 and error messages' do
        get '/error'

        expect(last_response.status).to eq 500
        expect(JSON.parse(last_response.body)).to eq expected
      end
    end
    context 'DELETE /api/todos and an error happens' do
      before do
        Todo.any_instance.stub(:destroy){ fail }
      end

      it 'returns 500 and error messages' do
        delete '/api/todos/hoge'

        expect(last_response.status).to eq 500
        expect(JSON.parse(last_response.body)).to eq expected
      end
    end
  end

end
