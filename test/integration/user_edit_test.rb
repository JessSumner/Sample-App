require 'test_helper'

class UserEditTest < ActionDispatch::IntegrationTest
  def setup
  	@user = users(:testuser)
  end

  test "unsuccessful edit" do
  	get edit_user_path(@user)
  	assert_template 'users/edit'
  	patch user_path(@user), user: {name: "",
  								   email: "foo@invalid",
  								   password: "foo",
  								   password_confirmation: "bar"}
  	assert_template 'users/edit'
  end

  test "successful edit" do
  	get edit_user_path(@user)
  	assert_template 'users/edit'
  	name = "Foo Bar"
  	email = "email@foobar.com"
  	patch user_path(@user), user: { name: name,
  								    email: email,
  								    password: "",
  									password_confirmation: ""}
  	assert flash.present?
  	assert_redirected_to @user
  	@user.reload
  	assert_equal name, @user.name
  	assert_equal email, @user.email
  end
end

