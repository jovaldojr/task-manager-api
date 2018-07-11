require 'rails_helper'

RSpec.describe 'Users API', type: :request do 
	let!(:user) { create(:user) }
	let(:user_id) { user.id }
	let(:headers) do 
		{
			'Accept' => 'application/vnd.taskmanager.v2',
			'Content-Type' => Mime[:json].to_s,
			'Authorization' => user.auth_token
		}
	end

	before { host! 'api.taskmanager.test' }

	describe 'GET /users/:id' do
		before do
			get "/users/#{user_id}", params: {}, headers: headers
		end

		context 'when the user exists' do
			it 'returns the user' do
				expect(json_body[:id]).to eq(user_id)
			end
			# staus Ok
			it 'returns status code 200' do
				expect(response).to have_http_status(200)
			end
		end

		# staus Usuario Não existe
		context 'when the user does not exists' do
			let(:user_id) { 100000 } # Definindo novo usuário para testar o usuário
			it 'returns status code 404' do
				expect(response).to have_http_status(404)
			end
		end
	end

	describe 'POST /users' do
		
		before do
			post '/users', params: { user: user_params }.to_json , headers: headers
		end

		context	'when the request params are valid' do
			let(:user_params) { attributes_for(:user) }

			it 'returns status code 201' do
				expect(response).to have_http_status(201)
			end

			it 'returns json data for the created user' do
				expect(json_body[:email]).to eq(user_params[:email])
			end

		end

		context	'when the request params are invalid' do
			let(:user_params) { attributes_for(:user, email: 'invalid_email@') }

			it 'returns status code 422' do
				expect(response).to have_http_status(422)
			end

			it 'returns the jason data for the erros' do
				expect(json_body).to have_key(:errors)
			end
		end
	end

	describe 'PUT /users/:id' do
		before do
			put "/users/#{user_id}", params: { user: user_params }.to_json, headers: headers
		end

		context	'when the request params are valid' do
			let(:user_params) { { email: 'new_email@testeemail.com' } }

			it 'returns status code 200' do
				expect(response).to have_http_status(200)
			end

			it 'returns json data for the update user' do
				expect(json_body[:email]).to eq(user_params[:email])
			end
		end

		context	'when the request params are invalid' do
			let(:user_params) { { email: 'invalid_email@' } }

			it 'returns status code 422' do
				expect(response).to have_http_status(422)
			end

			it 'returns the jason data for the erros' do
				expect(json_body).to have_key(:errors)
			end
		end		
	end

	describe 'DELETE /users/:id' do
		before do
			delete "/users/#{user_id}", params: {}, headers: headers			
		end

		it 'returns status code 204' do
			expect(response).to have_http_status(204)
		end

		it 'removes the user from database' do
			expect( User.find_by(id: user.id) ).to be_nil
		end

	end
end