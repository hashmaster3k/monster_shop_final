require 'rails_helper'

RSpec.describe 'DISCOUNT PORTAL DELETE' do
  before :each do
    @bike_shop = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)

    @tire = @bike_shop.items.create(name: "Gatorskins",
                                    description: "They'll never pop!",
                                    price: 100,
                                    image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588",
                                    inventory: 12)

    @chain = @bike_shop.items.create(name: "2 Chains",
                                     description: "A set of two chains",
                                     price: 50,
                                     image: "https://ae01.alicdn.com/kf/H8f6e71c582f6409ebf1374828507faefM.jpg",
                                     inventory: 6)

    @discount = @tire.discounts.create(discount_percent: 5.0,
                                       minimum_quantity: 10)

    @merchant = User.create!(name: 'Billy Bike Merchant',
                            address: '125 Song St.',
                            city: 'Las Vegas',
                            state: 'NV',
                            zip: '12345',
                            email: 'bike_merchant@shop.com',
                            password: '123',
                            merchant_id: @bike_shop.id,
                            role: 1)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
  end

  describe 'a merchant user' do
    it 'can delete an active discount for an item' do
      visit '/merchant/discounts'

      within "#item-#{@tire.id}" do
        expect(page).to have_content('Active discounts')
        expect(page).to have_content('5.0% on 10 or more items')
        expect(page).to have_link('delete discount')
        click_link 'delete discount'
      end

      expect(current_path).to eq('/merchant/discounts')
      expect(page).to have_content('Discount successfully removed')

      within "#item-#{@tire.id}" do
        expect(page).to have_content('Active discounts')
        expect(page).to have_content('no active discounts')
        expect(page).to_not have_link('delete discount')
      end
    end
  end
end
