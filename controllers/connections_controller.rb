class ConnectionsController < ApplicationController
  before_action :authenticate_user
  before_action :ensure_correct_group,{only:[:unsubscribe]}

  def ensure_correct_group
    if Connection.find_by(user_id: @current_user.id, group_id: params[:id]) == nil
      flash[:notice] = "そのグループには入っていません"
      redirect_to("/groups/home")
    end
  end

  def join
    # メールアドレスのみを用いて、ユーザーを取得
    @group = Group.find_by(password_digest: params[:password])
    @user = User.find_by(id: session[:user_id])
    @connection = Connection.new(user_id: @user.id, group_id: @group.id)
    # if文の条件を&&とauthenticateメソッドを用いて書き換え
    if @group && @group.name = params[:name] && Connection.find_by(user_id: @user.id, group_id: @group.id) == nil
      # @userが存在すること     # フォームから送信されたパスワードと暗号化されたパスワードが一致すること
      @connection.save
      flash[:notice] = "グループに入りました"
      redirect_to("/groups/#{@group.id}")
    elsif @group && @group.name = params[:name] && Connection.find_by(user_id: @user.id, group_id: @group.id) != nil
      flash[:notice] = "このグループにはすでに入っています"
      redirect_to("/groups/#{@group.id}")
    else
      @error_message = "グループ名またはグループコードが間違っています"
      @name = params[:name]
      @password = params[:password]
      render("groups/join_form")
    end
  end

  def unsubscribe
    @group = Group.find_by(id: params[:group_id])
    @connection = Connection.find_by(user_id: @current_user.id, group_id: @group.id)
    @connection.destroy
#    @connentions = Connection.where(group_id: @group.id)
#    if @connections.present? == false
#      @posts = Post.where(group_id: @group.id)
#      @posts.destroy_all
#      @group.destroy
#    end
    flash[:notice] = "グループを退会しました"
    redirect_to("/groups/home")
  end

  def force_unsubscribe
    @group = Group.find_by(id: params[:group_id])
    @user = User.find_by(id: params[:user_id])
    @connection = Connection.find_by(user_id: @user.id, group_id: @group.id)
    @connection.destroy
    flash[:notice] = "#{@user.name}をグループから退会させました"
    redirect_to("/groups/#{@group.id}/members")#　ページの再読み込み
  end
end
