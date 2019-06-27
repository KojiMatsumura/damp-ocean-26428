require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  #test "should get index" do
  #  get posts_index_url
  #  assert_response :success
  #end

  test "should get all index" do
    get "/posts/all_index"
    assert_response :success
  end #このページだけはログイン不要

end
