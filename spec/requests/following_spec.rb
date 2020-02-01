require 'rails_helper'

RSpec.describe 'Following', type: :request do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }

  before do
    users = create_list(:user, 5)
    user.following = users
    user.followers = users
    log_in_as(user)
  end

  it 'following page' do
    get following_user_path(user)
    expect(user.following.empty?).to be false
    assert_match user.following.count.to_s, response.body
    user.following.each do |user|
      assert_select 'a[href=?]', user_path(user)
    end
  end

  it 'followers page' do
    get followers_user_path(user)
    expect(user.followers.empty?).to be false
    assert_match user.followers.count.to_s, response.body
    user.followers.each do |user|
      assert_select 'a[href=?]', user_path(user)
    end
  end

  it 'should follow a user the standard way' do
    expect do
      post relationships_path, params: { followed_id: user2.id }
    end.to change(user.following, :count).by(1)
  end

  it 'should follow a user with Ajax' do
    expect do
      post relationships_path, xhr: true, params: { followed_id: user2.id }
    end.to change(user.following, :count).by(1)
  end

  it 'should unfollow a user the standard way' do
    user.follow(user2)
    relationship = user.active_relationships.find_by(followed_id: user2.id)

    expect do
      delete relationship_path(relationship)
    end.to change(user.following, :count).from(6).to(5)
  end

  it 'should unfollow a user with Ajax' do
    user.follow(user2)
    relationship = user.active_relationships.find_by(followed_id: user2.id)
    expect do
      delete relationship_path(relationship), xhr: true
    end.to change(user.following, :count)
  end
end