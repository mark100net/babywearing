require 'rails_helper'

RSpec.describe 'Carrier', type: :request do
  fixtures :carriers
  let(:carrier) { carriers(:carrier) }
  fixtures :users
  let(:user) { users(:user) }

  before do
    visit '/'
    sign_in user
  end

  scenario 'SHOW' do
    visit carriers_path
    click_link 'test carrier'

    expect(page).to have_content('test carrier')
    expect(page).to have_content('babywearing')
    expect(page).to have_content('test model')
  end

  scenario 'EDIT with all required fields' do
    visit edit_carrier_path(carrier.id)

    fill_in 'Name', with: 'Updated Name'
    fill_in 'Model', with: 'Updated Model'
    click_on 'Update Carrier'

    expect(page).to have_content('Updated Name')
    expect(page).to have_content('Updated Model')
  end

  scenario 'EDIT without name' do
    visit edit_carrier_path(carrier.id)

    fill_in 'Name', with: ''
    click_on 'Update Carrier'

    expect(page).to have_content('Name can\'t be blank')
  end

  scenario 'DESTROY' do
    visit carrier_path(carrier.id)

    click_on 'Delete'

    expect(page).to have_content('Carrier successfully destroyed')
  end

  scenario 'CREATE with all required fields' do
    visit new_carrier_path
    fill_in 'Name', with: 'Test Name'
    fill_in 'Item', with: 9
    fill_in 'Manufacturer', with: 'Test Manufacturer'
    fill_in 'Model', with: 'Test Model'
    fill_in 'Color', with: 'White'
    fill_in 'Size', with: 8
    fill_in 'Location', with: 1

    click_on 'Create Carrier'

    expect(page).to have_content('Carrier successfully created')
  end

  scenario 'CREATE without required fields' do
    visit new_carrier_path(carrier.id)

    click_on 'Create Carrier'

    expect(page).to have_content('Name can\'t be blank')
    expect(page).to have_content('Item can\'t be blank')
    expect(page).to have_content('Manufacturer can\'t be blank')
    expect(page).to have_content('Model can\'t be blank')
    expect(page).to have_content('Color can\'t be blank')
    expect(page).to have_content('Location can\'t be blank')
  end
end