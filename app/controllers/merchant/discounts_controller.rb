class Merchant::DiscountsController < Merchant::BaseController
  def index
    @items = Merchant.active_items_by_merchant_id(current_user.merchant_id)
  end
end
