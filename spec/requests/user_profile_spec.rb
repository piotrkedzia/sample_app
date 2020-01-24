require 'rails_helper'

RSpec.describe 'User profile', type: :request do
  include ApplicationHelper

  let(:user) { create(:user_with_microposts, microposts_count: 40) }

  it 'displays a profile page' do
    get user_path(user)
    assert_select 'title', full_title(page_title: user.name)
    assert_select 'h1', text: user.name
    assert_select 'h1>img.gravatar'
    expect(response.body).to match(user.microposts.count.to_s)
    assert_select 'div.pagination'
    user.microposts.paginate(page: 1).each do |micropost|
      expect(response.body).to match(micropost.content)
    end
  end
end