class Group < ApplicationRecord
  #has_secure_password
  #validates :name, {presence: true}
  validates :password_digest, {presence: true, uniqueness: true, length: { minimum: 3 }}

  validate :add_error_sample

  has_many :users, through: :connections
  has_many :connections#, dependent: :destroy
  accepts_nested_attributes_for :connections#, allow_destroy: true

  def add_error_sample
    # nameが空のときにエラーメッセージを追加する
    if name.blank?
      errors[:base] << "グループ名を入力して下さい"
    end


#    if password_digest.blank?
#      errors[:base] << "グループコードを入力して下さい"
#    elsif password_digest.length < 3
#      errors[:base] << "グループコードは３文字以上で入力して下さい"
#    elsif Group.find_by(password_digest: password_digest) != nil
#      errors[:base] << "他のグループとグループコードがかぶっています"
#    end

  end



  def user
    return User.find_by(id: self.user_id)
  end

end
