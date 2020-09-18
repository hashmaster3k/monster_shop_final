class Merchant::DiscountsController < Merchant::BaseController
  def index
    @items = Merchant.active_items_by_merchant_id(current_user.merchant_id)
  end

  def new
    @item = Item.find(params[:item])
    @discount = Discount.new(item_id: @item.id)
  end

  def create
    item = Item.find(params[:discount][:item_id])
    discount = Discount.new(discount_params)

    if discount.save
      flash[:success] = "Discount for #{item.name} now active!"
      redirect_to merchant_discounts_path
    else
    end
  end

  private
  def discount_params
    params.require(:discount).permit(:discount_percent, :minimum_quantity, :item_id)
  end
end
