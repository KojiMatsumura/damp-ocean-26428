class Repeat < ApplicationRecord
  def self.every_sunday
    days = Repeat.where(rep: "日曜日")
    if days.present?
      days.each do |day|
        post = Post.new(
          content: day.content,
          user_id: day.user_id,
          group_id: day.group_id,
          buyer_id: -1,
          shop: day.shop
          )
        post.save
      end
    end
  end

  def self.every_monday
    days = Repeat.where(rep: "月曜日")
    if days.present?
      days.each do |day|
        post = Post.new(
          content: day.content,
          user_id: day.user_id,
          group_id: day.group_id,
          buyer_id: -1,
          shop: day.shop
          )
        post.save
      end
    end
  end

  def self.every_tuesday
    days = Repeat.where(rep: "火曜日")
    if days.present?
      days.each do |day|
        post = Post.new(
          content: day.content,
          user_id: day.user_id,
          group_id: day.group_id,
          buyer_id: -1,
          shop: day.shop
          )
        post.save
      end
    end
  end

  def self.every_wednesday
    days = Repeat.where(rep: "水曜日")
    if days.present?
      days.each do |day|
        post = Post.new(
          content: day.content,
          user_id: day.user_id,
          group_id: day.group_id,
          buyer_id: -1,
          shop: day.shop
          )
        post.save
      end
    end
  end

  def self.every_thursday
    days = Repeat.where(rep: "木曜日")
    if days.present?
      days.each do |day|
        post = Post.new(
          content: day.content,
          user_id: day.user_id,
          group_id: day.group_id,
          buyer_id: -1,
          shop: day.shop
          )
        post.save
      end
    end
  end

  def self.every_friday
    days = Repeat.where(rep: "金曜日")
    if days.present?
      days.each do |day|
        post = Post.new(
          content: day.content,
          user_id: day.user_id,
          group_id: day.group_id,
          buyer_id: -1,
          shop: day.shop
          )
        post.save
      end
    end
  end

  def self.every_saturday
    days = Repeat.where(rep: "土曜日")
    if days.present?
      days.each do |day|
        post = Post.new(
          content: day.content,
          user_id: day.user_id,
          group_id: day.group_id,
          buyer_id: -1,
          shop: day.shop
          )
        post.save
      end
    end
  end

end
