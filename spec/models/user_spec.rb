require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Validations' do
    it { should allow_value('Example User').for(:name) }
    it { should allow_value('user@example.com').for(:email) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }

    it { should validate_length_of(:name).is_at_most(50) }
    it { should validate_length_of(:email).is_at_most(255) }

    %w[
      user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn
    ].each do |email|
      it { should allow_value(email).for(:email) }
    end

    %w[
      user@example,com user_at_foo.org user.name@example.foo@bar_baz.com
      foo@bar+baz.com foo@bar..com
    ].each do |email|
      it { should_not allow_value(email).for(:email) }
    end

    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }

    describe 'uniqueness of the email field' do
      before do
        create(:user, email: 'test@example.com')
      end

      it 'checks if an email has unique value' do
        duplicate_user = build(:user, email: 'test@example.com')
        expect(duplicate_user).to be_invalid
      end

      it 'checks if an email is unique and case insensive' do
        duplicate_user = build(:user, email: 'test@example.com'.upcase)
        expect(duplicate_user).to be_invalid
      end
    end
  end

  describe 'Downcase user email before save' do
    it 'persists downcase version of a user email' do
      user = create(:user, email: 'TEST@EXAMPLE.COM')
      expect(user.email).to eq 'test@example.com'
    end
  end

  it 'authenticated? should return false for a user with nil digest' do
    user = create(:user)
    expect(user.authenticated?(:remember, '')).to eq false
  end

  it 'should follow and unfollow a user' do
    user1 = create(:user)
    user2 = create(:user)

    expect(user1.following?(user2)).to eq false
    expect(user2.following?(user1)).to eq false

    user1.follow(user2)
    expect(user1.following?(user2)).to eq true
    expect(user2.followers).to include(user1)

    user1.unfollow(user2)
    expect(user1.following?(user2)).to eq false
  end
end
