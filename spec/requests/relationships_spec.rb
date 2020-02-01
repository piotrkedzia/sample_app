require 'rails_helper'

RSpec.describe 'Relationship', type: :request do
  let(:user) { create(:user) }

  it 'create should require logged-in user' do
    expect do
      post relationships_path
    end.to_not change(Relationship, :count)

    expect(response).to redirect_to login_url
  end

  it 'destroy should require logged-in user' do
    user2 = create(:user)
    user.following << user2

    expect do
      delete relationship_path(user2)
    end.to_not change(Relationship, :count)

    assert_redirected_to login_url
  end
end


