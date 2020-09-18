require 'rails_helper'

RSpec.describe 'DISCOUNT PORTAL INDEX PAGE' do
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
    it 'can visit their disount portal' do
      visit '/merchant/discounts'
    end

    it 'displays that merchants items and discount info' do
      visit '/merchant/discounts'

      within "#item-#{@tire.id}" do
        expect(page).to have_content("Item ##{@tire.id} - #{@tire.name}")
        expect(page).to have_content("Inventory: #{@tire.inventory}")
        expect(page).to have_content("Price: $#{@tire.price}")
        expect(page).to have_content("Active discounts")
        expect(page).to have_content("no active discounts")

      end

      within "#item-#{@chain.id}" do
        expect(page).to have_content("Item ##{@chain.id} - #{@chain.name}")
        expect(page).to have_content("Inventory: #{@chain.inventory}")
        expect(page).to have_content("Price: $#{@chain.price}")
        expect(page).to have_content("Active discounts")
        expect(page).to have_content("no active discounts")
      end
    end

    it 'has a link to add new discount to that item' do
      visit '/merchant/discounts'

      within "#item-#{@tire.id}" do
        expect(page).to have_link("add discount")
      end

      within "#item-#{@chain.id}" do
        expect(page).to have_link("add discount")
      end
    end

    it 'can add a new discount to an item' do
      visit '/merchant/discounts'

      within "#item-#{@chain.id}" do
        click_link "add discount"
      end

      expect(current_path).to eq("/merchant/discounts/new")
      expect(page).to have_content("#{@chain.name} Discount Creation")
      expect(page).to have_content("Discount percent")
      expect(page).to have_content("Minimum quantity")

      fill_in :discount_discount_percent, with: 5
      fill_in :discount_minimum_quantity, with: 10
      click_button 'Create Discount'

      expect(current_path).to eq('/merchant/discounts')
      expect(page).to have_content("Discount for #{@chain.name} now active!")

      within "#item-#{@chain.id}" do
        expect(page).to have_content("Item ##{@chain.id} - #{@chain.name}")
        expect(page).to have_content("Inventory: #{@chain.inventory}")
        expect(page).to have_content("Price: $#{@chain.price}")
        expect(page).to have_content("Active discounts")
        expect(page).to have_content("5.0% on 10 or more items")
      end
    end

    it 'cannot create a discount without filling in all fields' do
      visit '/merchant/discounts'

      within "#item-#{@chain.id}" do
        click_link "add discount"
      end

      fill_in :discount_discount_percent, with: ""
      fill_in :discount_minimum_quantity, with: 10
      click_button 'Create Discount'

      expect(page).to have_content("One or both fields was blank")
    end
  end
end
