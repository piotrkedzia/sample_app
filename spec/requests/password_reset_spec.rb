require 'rails_helper'

RSpec.describe 'Password Reset', type: :request do
  before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  let(:user) { create(:user) }

  describe 'Unsuccessful password reset' do
    it 'displays error message when email address does not exist' do
      get new_password_reset_path
      post password_resets_path, params: { password_reset: { email: '' } }

      expect(response.body).to match 'Email address not found'
    end

    it 'redirects to root_url when reset link contains invalid email' do
      post password_resets_path, params: { password_reset: { email: user.email } }

      reset_password_link =
        ActionMailer::Base.deliveries.last.body.encoded[/http(.*?)#{CGI.escape(user.email)}/]
      invalid_reset_link = reset_password_link.gsub(/=.*/, "=#{CGI.escape('fake@example.com')}")
      get invalid_reset_link

      expect(response).to redirect_to root_url
    end

    it 'redirects to root_url when user was not activated' do
      inactive_user = create(:user, activated: false)
      post password_resets_path, params: { password_reset: { email: inactive_user.email } }

      reset_password_link = ActionMailer::Base
                            .deliveries
                            .last
                            .body
                            .encoded[/http(.*?)#{CGI.escape(inactive_user.email)}/]
      get reset_password_link

      expect(response).to redirect_to root_url
    end

    it 'redirects to root_url when a reset token is invalid' do
      post password_resets_path, params: { password_reset: { email: user.email } }

      reset_password_link =
        ActionMailer::Base.deliveries.last.body.encoded[/http(.*?)#{CGI.escape(user.email)}/]

      invalid_reset_link = reset_password_link.gsub(%r{(?<=resets\/)[^\/]+(?=\/edit)}, 'fake_token')
      get invalid_reset_link

      expect(response).to redirect_to root_url
    end

    it 'shows errors message when a new password and password confirmation do not match' do
      post password_resets_path, params: { password_reset: { email: user.email } }

      reset_password_link =
        ActionMailer::Base.deliveries.last.body.encoded[/http(.*?)#{CGI.escape(user.email)}/]
      reset_token = reset_password_link[%r{(?<=resets\/)[^\/]+(?=\/edit)}]

      params = {
        email: user.email,
        user: {
          password: 'foo',
          password_confirmation: 'bar'
        }
      }
      patch password_reset_path(reset_token), params: params

      assert_select 'div#error_explanation'
    end

    it 'shows errors message when a new password and password confirmation are empty' do
      post password_resets_path, params: { password_reset: { email: user.email } }

      reset_password_link =
        ActionMailer::Base.deliveries.last.body.encoded[/http(.*?)#{CGI.escape(user.email)}/]
      reset_token = reset_password_link[%r{(?<=resets\/)[^\/]+(?=\/edit)}]

      params = {
        email: user.email,
        user: {
          password: '',
          password_confirmation: ''
        }
      }
      patch password_reset_path(reset_token), params: params

      assert_select 'div#error_explanation'
    end
  end

  describe 'Successful password reset' do
    it 'sends an email with reset token' do
      expect(ActionMailer::Base.deliveries.count).to eq 0
      post password_resets_path, params: { password_reset: { email: user.email } }
      expect(ActionMailer::Base.deliveries.count).to eq 1

      reset_password_link =
        ActionMailer::Base.deliveries.last.body.encoded[/http(.*?)#{CGI.escape(user.email)}/]
      expect(reset_password_link.size).to be > 0
    end

    it 'redirects to a change password form' do
      post password_resets_path, params: { password_reset: { email: user.email } }

      reset_password_link =
        ActionMailer::Base.deliveries.last.body.encoded[/http(.*?)#{CGI.escape(user.email)}/]

      get reset_password_link

      assert_select 'input[name=email][type=hidden][value=?]', user.email
    end

    it 'logs in user after successful password reset' do
      post password_resets_path, params: { password_reset: { email: user.email } }

      reset_password_link =
        ActionMailer::Base.deliveries.last.body.encoded[/http(.*?)#{CGI.escape(user.email)}/]
      reset_token = reset_password_link[%r{(?<=resets\/)[^\/]+(?=\/edit)}]

      params = {
        email: user.email,
        user: {
          password: 'secret_password',
          password_confirmation: 'secret_password'
        }
      }

      expect(is_logged_in?).to be false

      patch password_reset_path(reset_token), params: params

      expect(is_logged_in?).to be true
      expect(response).to redirect_to user
    end
  end
end
