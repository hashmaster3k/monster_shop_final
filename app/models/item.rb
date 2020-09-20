class Item < ApplicationRecord
  belongs_to :merchant
  has_many :order_items
  has_many :orders, through: :order_items
  has_many :reviews, dependent: :destroy
  has_many :discounts

  validates_presence_of :name,
                        :description,
                        :image,
                        :price,
                        :inventory

  def self.active_items
    where(active: true)
  end

  def self.by_popularity(limit = nil, order = "DESC")
    left_joins(:order_items)
    .select('items.id, items.name, COALESCE(sum(order_items.quantity), 0) AS total_sold')
    .group(:id)
    .order("total_sold #{order}")
    .limit(limit)
  end

  def sorted_reviews(limit = nil, order = :asc)
    reviews.order(rating: order).limit(limit)
  end

  def average_rating
    reviews.average(:rating)
  end

  def has_applicable_discount(quantity)
    discounts.where("#{quantity} >= minimum_quantity").length > 0
  end

  def display_subtotal_with_discount(quantity, price)
    price_adjusted(quantity) * quantity
  end

  def price_adjusted(quantity)
    price - ((applicable_discount(quantity).discount_percent / 100) * price)
  end

  def applicable_discount(quantity)
    discounts.where("minimum_quantity <= #{quantity}").order(minimum_quantity: :desc).first
  end
end
