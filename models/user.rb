class User < ApplicationRecord
  has_secure_password
  #validates :name, {presence: true}
  validates :email, {uniqueness: true}

  has_many :groups, through: :connections
  has_many :connections#, dependent: :destroy

  validate :add_error_sample

  def add_error_sample
    # nameが空のときにエラーメッセージを追加する
    if name.blank?
      errors[:base] << "ユーザー名を入力して下さい"
    end

    if email.blank?
      errors[:base] << "メールアドレスを入力して下さい"
    #elsif User.find_by(email: email) != nil
    #  errors[:base] << "そのアドレスは登録済です"
    end
  end



  def posts
    return Post.where(user_id: self.id)
  end

  def group
    return Group.find_by(id: self.group_id)
  end

  def user
    return User.find_by(id: self.user_id)
  end
end
