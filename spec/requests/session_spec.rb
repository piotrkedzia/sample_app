require 'rails_helper'

RSpec.describe 'Session', type: :request do
  describe 'New session' do
    it 'gets a new session page' do
      get login_path
      expect(response).to have_http_status(:success)
    end

    describe 'Log in with invalid information' do
      it 'displays the error message' do
        get login_path
        expect(response.body).to_not include('Invalid email or password')

        post login_path, params: { session: { email: 'test@example.com', password: 'start123' } }
        expect(response.body).to include('Invalid email or password')

        get root_path
        expect(response.body).to_not include('Invalid email or password')
        expect(is_logged_in?).to be false
      end
    end

    describe 'Log in with valid information' do
      let(:user_attributes) { attributes_for(:user) }

      it 'logs in user and redirect to user profile page' do
        user = create(:user, user_attributes)
        get login_path

        post login_path, params: { session: { email: user_attributes[:email], password: user_attributes[:password]}}

        expect(response).to redirect_to(user)
        follow_redirect!

        expect(response.body).to include(user.name)
        expect(response.body).to include('gravatar')
        expect(is_logged_in?).to be true
      end

      it 'it is possible to log out user' do
        create(:user, user_attributes)

        get login_path

        post login_path, params: { session: { email: user_attributes[:email], password: user_attributes[:password]}}

        expect(is_logged_in?).to be true
        follow_redirect!

        delete logout_path
        expect(is_logged_in?).to be false
        expect(response).to redirect_to root_url
      end
    end
  end
end