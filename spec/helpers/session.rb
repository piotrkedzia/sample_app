module Helpers
  module Session
    def is_logged_in?
      !session[:user_id].nil?
    end

    def log_in_as(user, password: 'start123', remember_me: '1')
      post(
        login_path,
        params: {
          session: { email: user.email, password: password, remember_me: remember_me }
        }
      )
    end
  end
end