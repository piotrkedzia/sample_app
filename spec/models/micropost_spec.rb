require 'rails_helper'

RSpec.describe Micropost, type: :model do
  subject { build(:micropost) }

  describe 'Validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_most(140) }
    it { should_not allow_value('   ').for(:content) }
  end

  describe 'Default order' do
    it 'sorts the most recent microposts as first' do
      user = create(:user)
      5.times { |n| create(:micropost, user_id: user.id, content: "content_#{n}") }

      micropost = Micropost.first
      expect(micropost.content).to eq('content_4')
    end
  end

  it 'destroys user with associated microposts' do
    expect(Micropost.count).to eq 0
    user = create(:user_with_microposts)
    expect(Micropost.count).to eq 5

    user.destroy
    expect(Micropost.count).to eq 0
  end
end
