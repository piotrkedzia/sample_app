class ApplicationController < ActionController::Base
  p "Hello from controller!"
  p "hfsdfadsf"

  def hello
    render html: "Hello"
  end
end
