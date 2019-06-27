require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  #before do
  #  @user = posts(:user)
  #  post '/login', {:name => @user.name, :password => @user.password}
  #end

  #test "find one" do
  #  assert_equal "卵", posts(:one).content #データは拾えているみたい
  #end

  test "should save post with content" do
    @one = posts(:post_one)
    assert @one.save
  end

  test "should not save post without content" do
    @two = posts(:post_two)
    assert !@two.save
  end
  #必ず通る

end
