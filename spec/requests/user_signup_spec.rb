require 'rails_helper'

RSpec.describe 'User Signup', type: :request do
  before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe 'Invalid signup information' do
    it 'returns error when there is missing user data' do
      post signup_path, params: { user: attributes_for(:user, name: '') }
      expect(response.body).to include("errors")
    end

    it 'returns error when there is missing user name' do
      post signup_path, params: { user: attributes_for(:user, name: '') }
      expect(response.body).to include(CGI.escapeHTML("Name can't be blank"))
    end

    it 'does not persist user with invalid data' do
      expect do
        post signup_path, params: { user: attributes_for(:user, name: '') }
      end.to_not change(User, :count)
    end
  end

  describe 'Valid signup information' do
    it 'does not return error' do
      post signup_path, params: { user: attributes_for(:user) }
      expect(response.body).to_not include("error")
    end

    it 'persists user' do
      expect do
        post signup_path, params: { user: attributes_for(:user) }
      end.to change(User, :count).by(1)
    end

    it 'sends a activation email' do
      expect(ActionMailer::Base.deliveries.size).to eq 0

      user_attributes = attributes_for(:user)
      post signup_path, params: { user: user_attributes }
      expect(response).to redirect_to root_url
      follow_redirect!
      expect(response.body).to match('Please check your email to activate your account.')
      expect(ActionMailer::Base.deliveries.size).to eq 1

      user = User.find_by(email: user_attributes[:email])
      expect(user.activated).to eq false
    end

    it 'is not possible to log in without activation' do
      user_attributes = attributes_for(:user)
      post signup_path, params: { user: user_attributes }

      user = User.find_by(email: user_attributes[:email])

      # try to log in
      log_in_as(user)
      follow_redirect!
      expect(response.body).to match('Account not activated')

      user.reload
      expect(user.activated).to eq false
      expect(is_logged_in?).to eq false
    end

    it 'is possible to log in after activation process' do
      user_attributes = attributes_for(:user)
      post signup_path, params: { user: user_attributes }

      user = User.find_by(email: user_attributes[:email])
      expect(user.activated).to eq false

      activation_link =
        ActionMailer::Base.deliveries.last.body.encoded[/http(.*?)#{CGI.escape(user.email)}/]
      get activation_link
      follow_redirect!
      expect(is_logged_in?).to eq true
      expect(response.body).to match('Account activated!')

      user.reload
      expect(user.activated).to eq true
      expect(is_logged_in?).to eq true
    end

    it 'is not possible to log in with invalid activation token' do
      user_attributes = attributes_for(:user)
      post signup_path, params: { user: user_attributes }

      user = User.find_by(email: user_attributes[:email])

      get edit_account_activation_path('fake_token', email: user.email)
      follow_redirect!
      expect(is_logged_in?).to eq false
      expect(response.body).to match('Invalid activation link')
    end
  end
end