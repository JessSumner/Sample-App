require 'test_helper'

class UserTest < ActiveSupport::TestCase
 	def setup
 	  @user = User.new(name: "Example User", email: "user@example.com",
 	  				   password: "foobar", password_confirmation: "foobar")
	end

	test "should be valid" do
		assert @user.valid?
	end

	test "name should be present" do
		@user.name = "      "
		assert @user.invalid?
	end

	test "email should be present" do
		@user.email = "     "
		assert_not @user.valid?
	end

	test "name should not be too long" do
		@user.name = "a" * 51
		assert_not @user.valid?
	end

	test "email should not be too long" do
		@user.email = "a" * 244 +"@example.com"
		assert_not @user.valid?
	end

	test "email validation should accept valid addesses" do
		valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bad.org 
							first.last@foo.jp alice+bob@baz.cn]
		valid_addresses.each do |valid_address|
			@user.email = valid_address
			assert @user.valid?, "#{valid_address.inspect} should be valid"
		end
	end

	test "email validation should reject invalid addresses" do
		invalid_addresses = %w[user@example,com user_at_foo.org
							 user.name@example. foo@bar_bar.com foo@bar+bar.com,
							 foo@bar..com]
		invalid_addresses.each do |invalid_address|
			@user.email = invalid_address
			assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
		end
	end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert duplicate_user.invalid?
  end

  test "email address should be saved as lower-case" do
  	mixed_case_email = "Foo@eXampLE.CoM"
  	@user.email = mixed_case_email
  	@user.save
  	assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
  	@user.password = @user.password_confirmation = " " * 6
  	assert @user.invalid?
  end

  test "password should have a minimum length" do
  	@user.password = @user.password_confirmation = "a" * 5
  	assert @user.invalid?
  end

  test "authenticated? should return false for a user with nil digest" do
  	assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
  	@user.save
  	@user.microposts.create!(content: "Lorem ipsum")
  	assert_difference 'Micropost.count', -1 do
  		@user.destroy
  	end
  end

  test "should follow and unfollow a user" do
    testuser = users(:testuser)
    archer = users(:archer)
    assert_not testuser.following?(archer)
    testuser.follow(archer)
    assert testuser.following?(archer)
    assert archer.followers.include?(testuser)
    testuser.unfollow(archer)
    assert_not testuser.following?(archer)
  end

  test "feed should have the right posts" do
    testuser = users(:testuser)
    archer   = users(:archer)
    mallory  = users(:mallory)
    # Posts from followed user
    testuser.microposts.each do |post_following|
      assert archer.feed.include?(post_following)
    end
    # Posts from self
    archer.microposts.each do |post_self|
      assert archer.feed.include?(post_self)
    end
    # Posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not testuser.feed.include?(post_unfollowed)
    end
  end
end
