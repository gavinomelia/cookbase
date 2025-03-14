require 'rails_helper'
require 'vcr'
require 'factory_bot_rails'

RSpec.describe User, type: :model do
  let(:user) { build(:user, email: "test-#{SecureRandom.hex(5)}@example.com") }

  it "is valid with valid attributes" do
    expect(user).to be_valid
  end

  it "is not valid without an email" do
    user.email = nil
    expect(user).to_not be_valid
  end

  it "is not valid with a duplicate email" do
    user.save!
    duplicate_user = build(:user, email: user.email)
    expect(duplicate_user).to_not be_valid
  end

  it "is not valid with a short password" do
    user.password = '12'
    user.password_confirmation = '12'
    expect(user).to_not be_valid
  end

  it "is not valid without a password confirmation" do
    user.password_confirmation = nil
    expect(user).to_not be_valid
  end

  it "is not valid with a mismatched password confirmation" do
    user.password_confirmation = 'different'
    expect(user).to_not be_valid
  end
end
