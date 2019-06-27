class GroupsController < ApplicationController
  before_action :authenticate_user
  #before_action :ensure_correct_user
  before_action :ensure_correct_group,{only:[:show, :gcreate, :destroy, :members, :edit, :update]}# 
  before_action :ensure_correct_admin,
  {only: [:admin_gedit, :admin_gupdate, :admin_gdestroy, :admin_unsubscribe]}

PER = 10

  def ensure_correct_group
    if Connection.find_by(user_id: @current_user.id, group_id: params[:group_id]) == nil
      flash[:notice] = "そのグループには入っていません"
      redirect_to("/groups/home")
    end
  end

  def ensure_correct_admin #管理者しかできない
    if @current_user.admin == false
      flash[:notice] = "権限がありません"
      redirect_to("/posts/index")
    end
  end

  def home
    @connections = Connection.where(user_id: @current_user.id)
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(name: params[:name],
                     password_digest: params[:password],
                     image_name: "default_group.png")
    if @group.save
      @connection = Connection.new(user_id: @current_user.id, group_id: @group.id)
      @connection.save
      flash[:notice] = "グループを作成しました"
      redirect_to("/groups/#{@group.id}")
    else
      render("groups/new")
    end
  end

  def join_form
  end

  def gshow
    @group = Group.find_by(id: params[:group_id])
    @posts = Post.where(group_id: @group.id, buyer_id: -1).page(params[:page]).per(PER)
    @post = Post.new
    @connections = Connection.where(group_id: @group.id).page(params[:page]).per(PER)
    @repeats = Repeat.where(group_id: @group.id).page(params[:page]).per(PER)
    #@postss = @posts.where(shop: "スーパー")
    #@postsda = @posts.where(shop: "100円ショップ")
    #@postsdo = @posts.where(shop: "ドンキ")
    #@postsc = @posts.where(shop: "衣料品店")
    #@postso = @posts.where(shop: "その他")
    @days = [@sundays, @mondays, @tuesdays, @wednesdays, @thursdays, @fridays, @saturdays]
    @days_j = ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"]
    for j in 0..6 do
      @days[j] = Repeat.where(group_id: @group.id, rep: @days_j[j]).page(params[:page]).per(PER)
    end
  end

  def destroy
    @group = Group.find_by(id: params[:group_id])
    @connections = Connection.where(group_id: @group.id)
    @connections.destroy_all
    @posts = Post.where(group_id: @group.id)
    @posts.destroy_all
    @repeats = Repeat.where(group_id: @group.id)
    @repeats.destroy_all
    @group.destroy
    flash[:notice] = "グループを解散しました" # 投稿削除のメッセージ。app/views/layouts/application.html.erbにHTMLの指定があるため、これだけで表示される
    redirect_to("/groups/home")
  end

  def members
    @group = Group.find_by(id: params[:group_id])
    @connections = Connection.where(group_id: @group.id).page(params[:page]).per(PER)
  end

  def edit
    @group = Group.find_by(id: params[:group_id])
  end

  def update
    @group = Group.find_by(id: params[:group_id]) # 入力したURLと同じidの値のpostを取得
    if params[:image]

    @group.image_name = "#{@group.id}.jpg"
 # groupインスタンスのimage_nameカラムの上書き
    image = params[:image]
               # フォームから画像ファイルを受け取る
    File.binwrite("public/group_images/#{@group.image_name}",image.read)
      # public/user_imagesフォルダに画像ファイルを作成。画像なのでbinwriteにする。image.readでファイルの中身が画像データであることを示す
    end
    @group.name = params[:name]
    @group.password_digest = params[:password] # この行で謎のエラー発生。3.5.0で解消
    if @group.save
      redirect_to("/groups/#{@group.id}") # /posts/indexに転送する（updateアクションでそのリンクに飛ぶ）
      flash[:notice] = "グループを編集しました"  # flashは、一度だけ表示されるもの
     else
      render("groups/edit")                   # 保存が失敗した時は編集ページに行く
          # redirect_to("posts/#{@post.id}/edit)だとeditアクションに転送→editアクション内のデータ（@post）== 編集前のデータを取得
          # render("フォルダ名/ファイル名")renderメソッドを使うと、そのアクション内で定義した@変数をビューでそのまま使える
      flash[:notice] = "グループを編集できませんでした"
    end
  end

  def admin_gedit
    @group = Group.find_by(id: params[:group_id])
    @posts = Post.where(group_id: @group.id)
    @connections = Connection.where(group_id: @group.id)
  end

  def admin_gupdate
    @group = Group.find_by(id: params[:group_id]) # 入力したURLと同じidの値のpostを取得
    @group.name = params[:name]
    @group.password_digest = params[:password] # この行で謎のエラー発生。3.5.0で解消
    if @group.save
      redirect_to("/admin") # /posts/indexに転送する（updateアクションでそのリンクに飛ぶ）
      flash[:notice] = "グループを編集しました"  # flashは、一度だけ表示されるもの
     else
      render("groups/admin_gedit")                   # 保存が失敗した時は編集ページに行く
          # redirect_to("posts/#{@post.id}/edit)だとeditアクションに転送→editアクション内のデータ（@post）== 編集前のデータを取得
          # render("フォルダ名/ファイル名")renderメソッドを使うと、そのアクション内で定義した@変数をビューでそのまま使える
      flash[:notice] = "グループを編集できませんでした"
    end
  end

  def admin_gdestroy
    @group = Group.find_by(id: params[:group_id])
    @connections = Connection.where(group_id: @group.id)
    @connections.destroy_all
    @posts = Post.where(group_id: @group.id)
    @posts.destroy_all
    @repeats = Repeat.where(group_id: @group.id)
    @repeats.destroy_all
    @group.destroy
    redirect_to("/admin")
  end

  def admin_unsubscribe
    @group = Group.find_by(id: params[:group_id])
    @user = User.find_by(id: params[:user_id])
    @connection = Connection.find_by(group_id: @group.id, user_id: @user.id)
    @connection.destroy
    redirect_to("/admin")
  end

end
