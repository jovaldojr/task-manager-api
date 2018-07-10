require 'rails_helper'

RSpec.describe Authenticable do 
	controller(ApplicationController) do
		include Authenticable
	end

	let(:app_controler) { subject }

	describe '#current_user' do
		let(:user) { create(:user) }

		before do
			req = double(:headers => { 'Authorization' => user.auth_token })
			allow(app_controler).to receive(:request).and_return(req)
		end

		it 'returns the user from the authorization header' do
			expect(app_controler.current_user).to eq(user)
		end
	end

	describe '#authenticate_with_token!' do
		controller do
			before_action :authenticate_with_token!

			def restricted_action; end
		end

		context 'when there is not user logged in' do
			before do
				allow(app_controler).to receive(:current_user).and_return(nil)
				routes.draw { get 'restricted_action' => 'anonymous#restricted_action' }
				get :restricted_action
			end

			it 'returns status code 401' do
				expect(response).to have_http_status(401)
			end

			it 'returns the jason data for the errors' do
				expect(json_body).to have_key(:errors)
			end
		end
	end
end