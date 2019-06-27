class Post < ApplicationRecord
  validates :content, {presence: true}
  validates :user_id, {presence: true}
  #validate :add_error_sample

  def add_error_sample
    # nameが空のときにエラーメッセージを追加する
    if content.blank?
      errors[:base] << "投稿内容を入力して下さい"
    end

  end

  def user
    return User.find_by(id: self.user_id)
  end

  def buyer
    return User.find_by(id: self.buyer_id)
  end

end
