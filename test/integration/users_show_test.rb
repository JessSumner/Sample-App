require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
 
 def setup
 	@user 	 	 = users(:testuser)
 	@activated	 = users(:archer)
 	@unactivated = users(:dummie)
 end

 #test "selecting an active user results in their show page" do
 #	log_in_as @user
 #	get user_path(@activated)
 #	assert_template 'user/'
 #end


 test "selecting an unactivated user's show page results in being redirected to the root" do
 	log_in_as @activated
 	get user_path(@unactivated)
 	assert_redirected_to root_url
 end
end