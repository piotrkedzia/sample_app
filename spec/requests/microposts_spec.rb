require 'rails_helper'

RSpec.describe 'Microposts', type: :request do
  let!(:user_with_posts) { create(:user_with_microposts) }

  describe 'Create micropost' do
    it 'should redirect create when not logged in' do
      post microposts_path, params: { micropost: { content: 'Lorem ipsum' } }
      expect(response).to redirect_to login_url
    end
  end

  describe 'Destroy micropost' do
    it 'should redirect destroy when not logged int' do
      delete micropost_path(user_with_posts.microposts.first)
      expect(response).to redirect_to login_url
    end

    it 'should redirect destroy for wrong micropost' do
      user_without_micropost = create(:user)
      log_in_as(user_without_micropost)

      expect do
        delete micropost_path(user_with_posts.microposts.first)
        expect(response).to redirect_to root_url
      end.to_not change(Micropost, :count)
    end

    it 'destroys micropost which belongs to user' do
      log_in_as(user_with_posts)

      expect do
        delete micropost_path(user_with_posts.microposts.first)
      end.to change(Micropost, :count)
    end
  end
end