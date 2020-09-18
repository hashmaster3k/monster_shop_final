class Discount < ApplicationRecord
  validates_presence_of :discount_percent, :minimum_quantity

  belongs_to :item
end
