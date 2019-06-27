class UsersController < ApplicationController
  before_action :authenticate_user,
  {only:[:index, :show, :edit, :update, :admin, :admin_edit, :admin_update, :admin_destroy]}
# before_actionを特定のアクションにのみ適用
  before_action :forbid_login_user,{only: [:new, :create, :login_form, :login]}
  before_action :ensure_correct_user, {only: [:edit, :update]}
  before_action :ensure_correct_admin,
  {only: [:admin, :admin_edit, :admin_update, :admin_destroy, :admin_new, :admin_cancel]}


PER = 10

  def ensure_correct_user#他人の投稿を編集不可能
    if @current_user.id != params[:user_id].to_i
 #paramsでは文字列になるので.to_iを使って数字にする
    flash[:notice] = "権限がありません"
    redirect_to("/posts/index")
    end
  end

  def ensure_correct_admin #管理者しかできない
    if @current_user.admin == false
      flash[:notice] = "権限がありません"
      redirect_to("/posts/index")
    end
  end

  def index
    @users=User.all
  end

  def show
    @user = User.find_by(id: params[:user_id])
    @posts = Post.where(user_id: @user.id).page(params[:page]).per(PER)
  end

  def new
    @user=User.new
  end

  def create
    @user = User.new(name: params[:name],
                     email: params[:email],
                     password: params[:password],
                     image_name: "default_user.png"
                   ) #写真があったが、消した
                   # params[:content]でフォームから送信されたデータを受け取り、
                              # contentの値ががparams[:content]であるインスタンスを作成。そのインスタンスをpostsのデータに送る
    if @user.save
      session[:user_id] = @user.id
      redirect_to("/posts/index")
    else
      render("users/new")
    end
  end

  def edit
    @user = User.find_by(id: params[:user_id]) #入力したURLと同じidの値のpostを取得
  end

  def update
    @user = User.find_by(id: params[:user_id]) # 入力したURLと同じidの値のpostを取得
    if params[:image]
    @user.image_name = "#{@user.id}.jpg"
    image = params[:image]
    File.binwrite("public/user_images/#{@user.image_name}",image.read)
      # public/user_imagesフォルダに画像ファイルを作成。画像なのでbinwriteにする。image.readでファイルの中身が画像データであることを示す
    end
    @user.name = params[:name]
    @user.email = params[:email] # この行で謎のエラー発生。3.5.0で解消
    if @user.save
      redirect_to("/users/#{@user.id}") # /posts/indexに転送する（updateアクションでそのリンクに飛ぶ）
      flash[:notice] = "ユーザーを編集しました"  # flashは、一度だけ表示されるもの
     else
      render("users/edit")                   # 保存が失敗した時は編集ページに行く
          # redirect_to("posts/#{@post.id}/edit)だとeditアクションに転送→editアクション内のデータ（@post）== 編集前のデータを取得
          # render("フォルダ名/ファイル名")renderメソッドを使うと、そのアクション内で定義した@変数をビューでそのまま使える
      flash[:notice] = "ユーザーを編集できませんでした"
    end
  end

  def login_form
  end

  def login
    # メールアドレスのみを用いて、ユーザーを取得
    @user = User.find_by(email: params[:email])
    # if文の条件を&&とauthenticateメソッドを用いて書き換え
    if @user && @user.authenticate(params[:password]) # @userが存在すること
                                                      # フォームから送信されたパスワードと暗号化されたパスワードが一致すること
      session[:user_id] = @user.id
      flash[:notice] = "ログインしました"
      redirect_to("/posts/index")
    else
      @error_message = "メールアドレスまたはパスワードが間違っています"
      @email = params[:email]
      @password = params[:password]
      render("users/login_form")
    end
  end

  def logout
    session[:user_id] = nil # sessionの値をnilにすることでログアウトできる
    flash[:notice] = "ログアウトしました"
    redirect_to("/login")
  end

  def admin
    @users = User.page(params[:page]).per(PER)
    @groups = Group.page(params[:page]).per(PER)
    @posts = Post.page(params[:page]).per(PER)
    @repeats = Repeat.all
    @days = [@sundays, @mondays, @tuesdays, @wednesdays, @thursdays, @fridays, @saturdays]
    @days_j = ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"]
    for j in 0..6 do
      @days[j] = Repeat.where(rep: @days_j[j]).page(params[:page]).per(PER)
    end
  end

  def author_login_form
  end

  def admin_login
    @user = User.find_by(email: params[:email])
    # if文の条件を&&とauthenticateメソッドを用いて書き換え
    if @user && @user.authenticate(params[:password]) && @user.admin == true
      # @userが存在すること      # フォームから送信されたパスワードと暗号化されたパスワードが一致すること
      session[:user_id] = @user.id
      flash[:notice] = "管理者としてログインしました"
      redirect_to("/admin")
    elsif @user && @user.authenticate(params[:password]) && @user.admin == false
      @error_message = "権限がありません"
      render("users/admin_login_form")
    else
      @error_message = "メールアドレスまたはパスワードが間違っています"
      @email = params[:email]
      @password = params[:password]
      render("users/admin_login_form")
    end
  end

  def admin_signup
  end

  def admin_edit
    @user = User.find_by(id: params[:user_id])
    @posts = Post.where(user_id: @user.id).page(params[:page]).per(PER)
  end

  def admin_update
    #    if params[:image]
    #
    #    @user.image_name = "#{@user.id}.jpg"
    # # userインスタンスのimage_nameカラムの上書き
    #    image = params[:image]
    #               # フォームから画像ファイルを受け取る
    #    File.binwrite("public/user_images/#{@user.image_name}",image.read)
    #
    #      # public/user_imagesフォルダに画像ファイルを作成。画像なのでbinwriteにする。image.readでファイルの中身が画像データであることを示す
    #    end
        @user = User.find_by(id: params[:user_id]) # 入力したURLと同じidの値のpostを取得
        @user.name = params[:name]
        @user.email = params[:email] # この行で謎のエラー発生。3.5.0で解消
        if @user.save
          redirect_to("/admin/#{@user.id}/edit") # /posts/indexに転送する（updateアクションでそのリンクに飛ぶ）
          flash[:notice] = "ユーザーを編集しました"  # flashは、一度だけ表示されるもの
         else
          render("users/admin_edit")                   # 保存が失敗した時は編集ページに行く
              # redirect_to("posts/#{@post.id}/edit)だとeditアクションに転送→editアクション内のデータ（@post）== 編集前のデータを取得
              # render("フォルダ名/ファイル名")renderメソッドを使うと、そのアクション内で定義した@変数をビューでそのまま使える
          flash[:notice] = "ユーザーを編集できませんでした"
        end
  end

  def admin_destroy
    @user = User.find_by(id: params[:user_id])
    @connections = Connection.where(user_id: @user.id)
    @connections.destroy_all
    @posts = Post.where(user_id: @user.id)
    @posts.destroy_all
    @repeats = Repeat.where(user_id: @user.id)
    @repeats.destroy_all
    @user.destroy
    redirect_to("/admin")
  end

  def admin_new
    @user = User.find_by(id: params[:user_id])
    @user.admin = true
    @user.save
    redirect_to("/admin")
  end

  def admin_cancel
    @user = User.find_by(id: params[:user_id])
    @user.admin = false
    @user.save
    redirect_to("/admin")
  end

end
