require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let!(:user) { create(:user) }

  describe 'GET /users_edits' do
    it 'renders a user edit form' do
      get root_path
      log_in_as(user)

      get edit_user_path(user)

      expect(response).to have_http_status(200)
      expect(response.body).to include('Update your profile')
      expect(response.body).to include(user.name)
      expect(response.body).to include(user.email)
    end

    it 'friendly forwards user to the edit page after log in process' do
      get edit_user_path(user)
      log_in_as(user)
      expect(response).to redirect_to edit_user_url(user)
    end
  end

  describe 'Unsuccessful edit' do
    it 'shows validation errors' do
      log_in_as(user)
      get edit_user_path(user)

      patch user_path(user), params: { user: attributes_for(:user, email: '') }
      expect(response.body).to include('error')
      expect(response.body).to include('Email is invalid')
      assert_select 'form[action=?]', user_path(user)
      assert_select 'div.alert.alert-danger', 'The form contains 2 errors'
    end
  end

  describe 'Successful edit' do
    it 'updates users data and redirects to profile page' do
      log_in_as(user)
      get edit_user_path(user)

      updated_attributes = {
        name: 'foo bar',
        email: 'foo@bar.com',
        password: '',
        password_confirmation: ''
      }

      patch user_path(user), params: { user: updated_attributes }
      expect(response.body).to_not include('error')
      expect(flash[:success]).to include('Profile updated')
      expect(response).to redirect_to(user)
      follow_redirect!

      expect(response.body).to include(updated_attributes[:name])

      user.reload
      expect(user.name).to eq(updated_attributes[:name])
      expect(user.email).to eq(updated_attributes[:email])
    end
  end

  describe 'User not logged in - edit' do
    it 'redirects from edit page to login form' do
      get edit_user_path(user)
      expect(response).to redirect_to login_url
      expect(flash).to_not be_empty
    end

    it 'redirects from update page to login form' do
      patch user_path(user), params: { user: { name: 'foo bar', email: 'foo@bar.com' } }
      expect(response).to redirect_to login_url
      expect(flash).to_not be_empty
    end
  end

  describe 'Edit someone\'s profile' do
    let(:other_user) { create(:user) }

    it 'redirects edit when logged in as wrong user' do
      log_in_as(other_user)
      get edit_user_path(user)

      expect(response).to redirect_to root_url
      expect(flash).to_not be_empty
    end

    it 'redirects update when logged in as wrong user' do
      log_in_as(other_user)
      patch user_path(user), params: { user: { name: 'baz', email: 'baz@bar.com' } }

      expect(response).to redirect_to root_url
      expect(flash).to_not be_empty
    end
  end

  describe 'Admin user' do
    it 'prevents regular user to send a admin = true attribute' do
      log_in_as(user)
      user_params = {
        user: {
          name: 'foo bar',
          email: 'foo@bar.com',
          admin: true
        }
      }
      patch user_path(user), params: user_params
      user.reload
      expect(user.admin).to be false
    end
  end

  describe 'GET /users' do
    it 'redirects index when not logged in' do
      get users_path
      expect(response).to redirect_to login_url
    end

    it 'displays pagination' do
      40.times { create(:user) }
      log_in_as(user)
      get users_path
      assert_select 'div.pagination'
    end

    it 'displays pagination and delete links as admin' do
      40.times { create(:user) }
      admin_user = create(:user, admin: true)
      log_in_as(admin_user)

      get users_path
      assert_select 'div.pagination'
      first_page_of_users = User.paginate(page: 1)
      first_page_of_users.each do |user|
        assert_select 'a[href=?]', user_path(user), text: user.name
        if user != admin_user
          assert_select 'a[href=?]', user_path(user), text: 'delete'
        end
      end
    end

    it 'does not display delete links as non-admin user' do
      log_in_as(user)
      get users_path
      assert_select 'a', text: 'delete', count: 0
    end
  end

  describe 'DELETE user' do
    it 'redirects destroy when not logged in' do
      expect do
        delete user_path(user)
      end.to_not change(User, :count)

      expect(response).to redirect_to login_url
    end

    it 'redirects destroy when logged in user is not admin' do
      log_in_as(user)
      other_user = create(:user)
      expect do
        delete user_path(other_user)
      end.to_not change(User, :count)

      expect(response).to redirect_to root_url
    end
  end
end
