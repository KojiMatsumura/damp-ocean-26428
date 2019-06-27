require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

#  def setup
#    @request.session["user_id"] = 1
#  end

  test "should get index" do
    #session = {'user_id' => 1}
    #add_session(session)
    @user_one = users(:user_one)
    post '/login', params: { user: { email: @user_one.email, password: @user_one.password_digest} }
    #post '/login', params: { session: { user_id: 1 } }
    #session[:user_id] = 1
    #@request.session["user_id"] = 1
    get '/users/index'
    assert_equal 980190963, session[:user_id] # sessionはあるけどredirect。多分sessionを変数としている
    assert_response :success #authenticate_userをコメントアウトするとOK.そうでなければ/loginにリダイレクト
  end

  test "should get login" do
    get "/login"
    assert_response :success
  end

end
