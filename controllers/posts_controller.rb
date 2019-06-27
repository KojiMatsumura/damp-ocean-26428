class PostsController < ApplicationController
  before_action :authenticate_user,{except:[:all_index]}
  before_action :ensure_correct_user,{only:[:edit, :update, :destroy, :buy, :return_list, :group_edit, :group_update]}
  before_action :ensure_correct_group,
                {only:[:gcreate, :group_buy, :group_show, :group_bought, :group_return_list, :group_edit, :group_update]}
  before_action :ensure_correct_admin,
                {only: [:admin_edit, :admin_update, :admin_destroy, :admin_quit]}

PER = 10

  def ensure_correct_group
    if Connection.find_by(user_id: @current_user.id, group_id: params[:group_id]) == nil
      flash[:notice] = "そのグループには入っていません"
      redirect_to("/groups/home")
    end
  end

  def ensure_correct_user
    @post = Post.find_by(id: params[:post_id])
    if @post.user_id != @current_user.id
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
    @posts = Post.where(user_id: @current_user.id, buyer_id: -1).page(params[:page]).per(PER)
    @repeats = Repeat.where(user_id: @current_user.id, group_id: nil)
    #@postss = @posts.where(shop: "スーパー")
    #@postsda = @posts.where(shop: "100円ショップ")
    #@postsdo = @posts.where(shop: "ドンキ")
    #@postsc = @posts.where(shop: "衣料品店")
    #@postso = @posts.where(shop: "その他")
    @days = [@sundays, @mondays, @tuesdays, @wednesdays, @thursdays, @fridays, @saturdays]
    @days_j = ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"]
    for j in 0..6 do
      @days[j] = Repeat.where(user_id: @current_user.id, group_id: nil, rep: @days_j[j]).page(params[:page]).per(PER)
    end
  end

  def all_index
    @posts = Post.where(buyer_id: -1).page(params[:page]).per(PER)
    @repeats = Repeat.all
    @days = [@sundays, @mondays, @tuesdays, @wednesdays, @thursdays, @fridays, @saturdays]
    @days_j = ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"]
    for j in 0..6 do
      @days[j] = Repeat.where(rep: @days_j[j]).page(params[:page]).per(PER)
    end
  end

  def show
    @id = params[:post_id]
    @post = Post.find_by(id: params[:post_id], buyer_id: -1)
    @user = User.find_by(id: @post.id)
  end

  def new
    @post = Post.new
    @user = User.find_by(id: @post.user_id)
    @days_j = ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"]
  end

  def create
    @repeat = params[:repeat]
    @post = Post.new(
        content: params[:content],
        user_id: @current_user.id,
        buyer_id: -1,
        shop: params[:shop]) # user_idの値をログインしているユーザーのidにする)
                                 # params[:content]でフォームから送信されたデータを受け取り、
                                 # contentの値ががparams[:content]であるインスタンスを作成。そのインスタンスをpostsのデータに送る
    if @post.save
      if @repeat == "繰り返さない"
        flash[:notice] = "投稿を作成しました" # 保存が成功したらメッセージを表示
      else
        @day = Repeat.new(content: params[:content], user_id: @current_user.id, shop: params[:shop],rep: @repeat)
        @day.save
        flash[:notice] = "投稿を作成しました。これから毎週#{@repeat}に同じ投稿がされます"
      end
      redirect_to("/posts/index")
    else
      render("posts/new") # 保存が失敗したら新規投稿ページに戻る
                        # render("フォルダ名/ビュー名")であり、ルーティングではない
    end
  end

  def edit
    @post = Post.find_by(id: params[:post_id], buyer_id: -1) #入力したURLと同じidの値のpostを取得
  end

  def update
    @post = Post.find_by(id: params[:post_id], buyer_id: -1) # 入力したURLと同じidの値のpostを取得
    @post.content = params[:content] # この行で謎のエラー発生。3.5.0で解消
    @post.shop = params[:shop]
    if @post.save
      redirect_to("/posts/index") # /posts/indexに転送する（updateアクションでそのリンクに飛ぶ）
      flash[:notice] = "投稿を編集しました"
    else
      render("posts/edit")                   # 保存が失敗した時は編集ページに行く
              # redirect_to("posts/#{@post.id}/edit)だとeditアクションに転送→editアクション内のデータ（@post）== 編集前のデータを取得
              # render("フォルダ名/ファイル名")renderメソッドを使うと、そのアクション内で定義した@変数をビューでそのまま使える
    end
    #def example
    #   Item.transaction(isolation: :read_committed) do
    # item1 = Item.new({name:"腕時計", price:23000})
    # item1.save!
    #item2 = Item.new({name:"オルガン", price:53000})
    #item2.save!
    #end
    #render plain:'保存に成功しました。'
  #rescue => e
  #   render plain: e.message
  #end

  #モデル名.transaction do
  # 例外が発生する可能性のある処理
#end
  # 正常に動作した場合の処理
#rescue => e
  # 例外が発生した場合の処理
  end

  def destroy
    @post = Post.find_by(id: params[:post_id]) # 入力したURLと同じidの値のpostを取得
    @post.destroy                         # 取得した投稿を削除
    flash[:notice] = "投稿を削除しました" # 投稿削除のメッセージ。app/views/layouts/application.html.erbにHTMLの指定があるため、これだけで表示される
    redirect_to("/posts/bought")
  end

  def gcreate
    @repeat = params[:repeat]
    @group = Group.find_by(id: params[:group_id])
    #@posts = Post.where(group_id: @group.id, buyer_id: -1)
    @connections = Connection.where(group_id: @group.id)
    @post = Post.new(
      content: params[:content],
      user_id: @current_user.id,
      group_id: @group.id,
      buyer_id: -1,
      shop: params[:shop]) # user_idの値をログインしているユーザーのidにする)
                                 # params[:content]でフォームから送信されたデータを受け取り、
                                 # contentの値ががparams[:content]であるインスタンスを作成。そのインスタンスをpostsのデータに送る
    if @post.save
      if @repeat == "繰り返さない"
        flash[:notice] = "投稿を作成しました" # 保存が成功したらメッセージを表示
      else
        @day = Repeat.new(content: params[:content], user_id: @current_user.id, group_id: @group.id, shop: params[:shop],rep: @repeat)
        @day.save
        flash[:notice] = "投稿を作成しました。これから毎週#{@repeat}に同じ投稿がされます"
      end
      redirect_to("/groups/#{@group.id}")
    else
      render("groups/show") # 保存が失敗したら新規投稿ページに戻る
                        # render("フォルダ名/ビュー名")であり、ルーティングではない
    end
  end

  def buy #購入リストに送る。個人の場合
    @post = Post.find_by(id: params[:post_id])
    @post.buyer_id = @current_user.id
    @post.save
    redirect_to("/posts/index")
  end

  def group_buy
    @post = Post.find_by(id: params[:post_id])
    @group = Group.find_by(id: params[:group_id])
    @post.buyer_id = @current_user.id
    @post.save
    redirect_to("/groups/#{@group.id}")
  end

  def group_show
    @id = params[:post_id]
    @post = Post.find_by(id: params[:post_id], buyer_id: -1)
    @user = User.find_by(id: @post.id)
    @group = Group.find_by(id: params[:group_id])
    @connection = Connection.find_by(user_id: @current_user.id, group_id: @group.id)
  end

  def bought
    @posts = Post.where(user_id: @current_user.id, buyer_id: @current_user.id).page(params[:page]).per(PER)
  end

  def return_list
    @post = Post.find_by(id: params[:post_id])
    @post.buyer_id = -1
    @post.save
    redirect_to("/posts/index")
  end

  def group_bought
    @group = Group.find_by(id: params[:group_id])
    @posts = Post.where(group_id: @group.id).where.not(buyer_id: -1).page(params[:page]).per(PER)
  end

  def group_return_list
    @group = Group.find_by(id: params[:group_id])
    @post = Post.find_by(id: params[:post_id])
    @post.buyer_id = -1
    @post.save
    redirect_to("/posts/#{@group.id}/bought")
  end

  def group_edit
    @post = Post.find_by(id: params[:post_id], buyer_id: -1)
    @group = Group.find_by(id: params[:group_id])
  end

  def group_update
    @group = Group.find_by(id: params[:group_id])
    @post = Post.find_by(id: params[:post_id], buyer_id: -1) # 入力したURLと同じidの値のpostを取得
    @post.content = params[:content] # この行で謎のエラー発生。3.5.0で解消
    @post.shop = params[:shop]
    if @post.save
      redirect_to("/groups/#{@group.id}") # /posts/indexに転送する（updateアクションでそのリンクに飛ぶ）
      flash[:notice] = "投稿を編集しました"  # flashは、一度だけ表示されるもの
    else
      render("posts/group_edit")                   # 保存が失敗した時は編集ページに行く
              # redirect_to("posts/#{@post.id}/edit)だとeditアクションに転送→editアクション内のデータ（@post）== 編集前のデータを取得
              # render("フォルダ名/ファイル名")renderメソッドを使うと、そのアクション内で定義した@変数をビューでそのまま使える
    end
  end

  def group_destroy
    @group = Group.find_by(id: params[:group_id])
    @post = Post.find_by(id: params[:post_id]) # 入力したURLと同じidの値のpostを取得
    @post.destroy                         # 取得した投稿を削除
    flash[:notice] = "投稿を削除しました" # 投稿削除のメッセージ。app/views/layouts/application.html.erbにHTMLの指定があるため、これだけで表示される
    redirect_to("/posts/#{@group.id}/bought")
  end

  def quit
    @day = Repeat.find_by(id: params[:day_id])
    @day.destroy
    flash[:notice] = "毎週投稿をやめました" # 投稿削除のメッセージ。app/views/layouts/application.html.erbにHTMLの指定があるため、これだけで表示される
    redirect_to("/posts/index")
  end

  def group_quit
    @group = Group.find_by(id: params[:group_id])
    @day = Repeat.find_by(id: params[:day_id])
    @day.destroy
    flash[:notice] = "毎週投稿をやめました" # 投稿削除のメッセージ。app/views/layouts/application.html.erbにHTMLの指定があるため、これだけで表示される
    redirect_to("/groups/#{@group.id}")
  end

  def admin_edit
    @post = Post.find_by(id: params[:post_id])
  end

  def admin_update
    @post = Post.find_by(id: params[:post_id], buyer_id: -1) # 入力したURLと同じidの値のpostを取得
    @post.content = params[:content] # この行で謎のエラー発生。3.5.0で解消
    @post.shop = params[:shop]
    if @post.save
      redirect_to("/admin") # /posts/indexに転送する（updateアクションでそのリンクに飛ぶ）
      flash[:notice] = "投稿を編集しました"  # flashは、一度だけ表示されるもの
    else
      render("posts/admin_edit")                   # 保存が失敗した時は編集ページに行く
              # redirect_to("posts/#{@post.id}/edit)だとeditアクションに転送→editアクション内のデータ（@post）== 編集前のデータを取得
              # render("フォルダ名/ファイル名")renderメソッドを使うと、そのアクション内で定義した@変数をビューでそのまま使える
    end
  end

  def admin_destroy
    @post = Post.find_by(id: params[:post_id])
    @post.destroy
    redirect_to("/admin")
  end

  def admin_quit
    @repeat = Repeat.find_by(id: params[:day_id])
    @repeat.destroy
    redirect_to("/admin")
  end

end
