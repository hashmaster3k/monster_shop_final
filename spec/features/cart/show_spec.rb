require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Cart Show Page' do
  describe 'As a Visitor' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 10 )
    end

    describe 'I can see my cart' do
      it "I can visit a cart show page to see items in my cart" do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        expect(page).to have_content("Total: #{number_to_currency((@ogre.price * 1) + (@hippo.price * 2))}")

        within "#item-#{@ogre.id}" do
          expect(page).to have_link(@ogre.name)
          expect(page).to have_content("#{number_to_currency(@ogre.price)}")
          expect(page).to have_content("1")
          expect(page).to have_content("#{number_to_currency(@ogre.price * 1)}")
          expect(page).to have_content("#{@megan.name}")
          expect(page).to have_link(@megan.name)
        end

        within "#item-#{@hippo.id}" do
          expect(page).to have_link(@hippo.name)
          expect(page).to have_content("#{number_to_currency(@hippo.price)}")
          expect(page).to have_content("2")
          expect(page).to have_content("#{number_to_currency(@hippo.price * 2)}")
          expect(page).to have_content("#{@brian.name}")
          expect(page).to have_link(@brian.name)
        end
      end

      it "I can visit an empty cart page" do
        visit '/cart'

        expect(page).to have_content('Your Cart is Empty!')
        expect(page).to_not have_button('Empty Cart')
      end
    end

    describe 'I can manipulate my cart' do
      it 'I can empty my cart' do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        click_button 'Empty Cart'

        expect(current_path).to eq('/cart')
        expect(page).to have_content('Your Cart is Empty!')
        expect(page).to have_content('Cart: 0')
        expect(page).to_not have_button('Empty Cart')
      end

      it 'I can remove one item from my cart' do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('Remove')
        end

        expect(current_path).to eq('/cart')
        expect(page).to_not have_content("#{@hippo.name}")
        expect(page).to have_content('Cart: 1')
        expect(page).to have_content("#{@ogre.name}")
      end

      it 'I can add quantity to an item in my cart' do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('+')
        end

        expect(current_path).to eq('/cart')
        within "#item-#{@hippo.id}" do
          expect(page).to have_content('3')
        end
      end

      it 'I can not add more quantity than the items inventory' do
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          expect(page).to_not have_button('+')
        end

        visit "/items/#{@hippo.id}"

        click_button 'Add to Cart'

        expect(page).to have_content("You have all the item's inventory in your cart already!")
      end

      it 'I can reduce the quantity of an item in my cart' do
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('-')
        end

        expect(current_path).to eq('/cart')
        within "#item-#{@hippo.id}" do
          expect(page).to have_content('2')
        end
      end

      it 'if I reduce the quantity to zero, the item is removed from my cart' do
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('-')
        end

        expect(current_path).to eq('/cart')
        expect(page).to_not have_content("#{@hippo.name}")
        expect(page).to have_content("Cart: 0")
      end
    end

    it 'can see added savings once hitting quantity' do
      Discount.create!(item_id: @hippo.id,
                       discount_percent: 5,
                       minimum_quantity: 5)

      visit item_path(@hippo)
      click_button 'Add to Cart'

      visit '/cart'

      within "#item-#{@hippo.id}" do
        expect(page).to have_content('$50.0')
        click_button('+')
        expect(page).to have_content('$100.0')
        click_button('+')
        expect(page).to have_content('$150.0')
        click_button('+')
        expect(page).to have_content('$200.0')
        click_button('+')
        expect(page).to have_content('$237.5')
        expect(page).to have_content('Applied savings discount!')
      end
    end

    it 'will add the best suited discount' do
      Discount.create!(item_id: @hippo.id,
                       discount_percent: 5,
                       minimum_quantity: 5)
      Discount.create!(item_id: @hippo.id,
                       discount_percent: 10,
                       minimum_quantity: 6)
      Discount.create!(item_id: @hippo.id,
                       discount_percent: 11,
                       minimum_quantity: 7)

      visit item_path(@hippo)
      click_button 'Add to Cart'

      visit '/cart'

      within "#item-#{@hippo.id}" do
        expect(page).to have_content('$50.0')
        click_button('+')
        expect(page).to have_content('$100.0')
        click_button('+')
        expect(page).to have_content('$150.0')
        click_button('+')
        expect(page).to have_content('$200.0')
        click_button('+')
        expect(page).to have_content('$237.5')
        click_button('+')
        expect(page).to have_content('$270.0')
        expect(page).to have_content('Applied savings discount!')
      end
    end
  end
end
