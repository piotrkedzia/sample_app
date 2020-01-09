require 'rails_helper'

RSpec.describe 'User Signup', type: :request do
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
  end
end