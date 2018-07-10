require 'rails_helper'

RSpec.describe 'Users API', type: :request do 
	let!(:user) { create(:user) }
	let(:user_id) { user.id }

	before { host! "api.taskmanager.test" }

	describe "GET /users/:id" do
		before do
			headers = { "Accept" => "application/vnd.taskmanager.v1" }
			get "/users/#{user_id}", params: {}, headers: headers
		end

		context "when the user exists" do
			it "returns the user" do
				user_response = JSON.parse(response.body)
				expect(user_response["id"]).to eq(user_id)
			end
			# staus Ok
			it "returns status code 200" do
				expect(response).to have_http_status(200)
			end
		end

		# staus Usuario Não existe
		context "when the user does not exists" do
			let(:user_id) { 100000 } # Definindo novo usuário para testar o usuário
			it "returns status code 404" do
				expect(response).to have_http_status(404)
			end
		end
	end

end