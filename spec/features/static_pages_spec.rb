require 'rails_helper'

describe 'Static pages' do
  it ' should render navigation links on the top navbar' do
    visit root_path

    expect(page).to have_link 'Home'
    expect(page).to have_link 'Help'
    expect(page).to have_link 'Log in'
  end

  describe 'Home page' do
    it 'should display a home page' do
      visit home_path

      expect(page).to have_text 'Welcome to the Sample App'
    end
  end

  describe 'Help page' do
    it 'should display a help page' do
      visit help_path

      expect(page).to have_text 'This is the help page'
    end
  end
end