require 'rails_helper'

RSpec.feature 'SignUps', type: :feature do
  it 'renders the Sign up page' do
    visit signup_path

    expect(page).to have_text('Sign up')
  end

  it 'displays a failure flash message in case of invalid user' do
    visit signup_path

    fill_in  'Name', with: ''

    click_button 'Create my account'

    expect(current_path).to eq(signup_path)
    expect(page).to have_selector('div.alert.alert-danger', text: 'Invalid data!')
  end

  it 'displays a success flash message in case of valid user' do
    user_attributes = attributes_for(:user)

    visit signup_path

    fill_in  'Name', with: user_attributes[:name]
    fill_in  'Email', with: user_attributes[:email]
    fill_in  'Password', with: user_attributes[:password]
    fill_in  'Confirmation', with: user_attributes[:password_confirmation]

    click_button 'Create my account'

    expect(current_path).to eq(user_path(User.last))
    expect(page).to have_selector('div.alert.alert-success', text: 'Welcome to the Sample App!')
  end
end
