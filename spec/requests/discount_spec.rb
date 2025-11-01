require 'rails_helper'

RSpec.describe 'Discounts', type: :request do
  before :each do
    login!
  end
  describe 'GET /index' do
    it 'should success' do
      get discounts_path, headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'should display discount' do
      discount = create(:discount_all)
      get discount_path(discount.code), headers: headers
      expect(response).to have_http_status(:success)
      result = JSON.parse(response.body, symbolize_names: true)
      data = result[:data]
      expect(data[:id]).to eq(discount.id.to_s)
      expect(data[:type]).to eq('discount')
      attributes = data[:attributes]
      expect(attributes[:code]).to eq(discount.code)
      expect(attributes[:supplier_code]).to eq(discount.supplier_code)
      expect(attributes[:brand_name]).to eq(discount.brand_name)
      expect(attributes[:item_code]).to eq(discount.item_code)
      expect(attributes[:item_type_name]).to eq(discount.item_type_name)
      expect(attributes[:discount1]).to eq(discount.discount1)
      expect(attributes[:discount2]).to eq(discount.discount2)
      expect(attributes[:discount3]).to eq(discount.discount3)
      expect(attributes[:discount4]).to eq(discount.discount4)
      expect(attributes[:start_time].to_time).to eq(discount.start_time)
      expect(attributes[:end_time].to_time).to eq(discount.end_time)
    end
  end

  describe 'POST /discounts' do
    it 'should create discount' do
      start_time = DateTime.new(2023, 2, 23)
      end_time = DateTime.new(2999, 12, 31, 23, 59, 59)
      item = create(:item)
      post discounts_path, headers: headers, params: { discount: {
        start_time: start_time.iso8601,
        end_time: end_time.iso8601,
        item_code: item.kodeitem,
        supplier_code: item.supplier1,
        item_type_name: item.jenis,
        brand_name: item.merek,
        discount1: 15,
        discount2: 25,
        discount3: 35,
        discount4: 45
      } }.to_json
      expect(response).to have_http_status(:created)

      result = JSON.parse(response.body, symbolize_names: true)
      data = result[:data]
      discount = Discount.find(data[:id])
      expect(data[:type]).to eq('discount')
      attributes = data[:attributes]
      expect(attributes[:code]).to eq(discount.code)
      expect(attributes[:supplier_code]).to eq(item.supplier1)
      expect(attributes[:brand_name]).to eq(item.merek)
      expect(attributes[:item_code]).to eq(item.kodeitem)
      expect(attributes[:item_type_name]).to eq(item.jenis)
      expect(attributes[:discount1]).to eq(15)
      expect(attributes[:discount2]).to eq(25)
      expect(attributes[:discount3]).to eq(35)
      expect(attributes[:discount4]).to eq(45)
      expect(attributes[:start_time].to_time).to eq(start_time)
      expect(attributes[:end_time].to_time).to eq(end_time)
    end
  end

  describe 'PUT /discounts/:code' do
    it 'should update discount' do
      start_time = DateTime.new(2023, 5, 23)
      end_time = DateTime.new(2999, 10, 0o1, 23, 59, 59)
      discount = create(:discount_all)
      old_discount_code = discount.code
      item = create(:item)
      patch discount_path(old_discount_code), headers: headers, params: { discount: {
        code: 'changed-code',
        start_time: start_time.iso8601,
        end_time: end_time.iso8601,
        item_code: item.kodeitem,
        supplier_code: item.supplier1,
        item_type_name: item.jenis,
        brand_name: item.merek,
        discount1: 50,
        discount2: 40,
        discount3: 30,
        discount4: 20
      } }.to_json
      expect(response).to have_http_status(:success)
      result = JSON.parse(response.body, symbolize_names: true)
      data = result[:data]
      expect(data[:id]).to eq(discount.id.to_s)
      expect(data[:type]).to eq('discount')
      attributes = data[:attributes]
      expect(attributes[:code]).to eq(old_discount_code), 'code shouldnt changed'
      expect(attributes[:supplier_code]).to eq(item.supplier1)
      expect(attributes[:brand_name]).to eq(item.merek)
      expect(attributes[:item_code]).to eq(item.kodeitem)
      expect(attributes[:item_type_name]).to eq(item.jenis)
      expect(attributes[:discount1]).to eq(50)
      expect(attributes[:discount2]).to eq(40)
      expect(attributes[:discount3]).to eq(30)
      expect(attributes[:discount4]).to eq(20)
      expect(attributes[:start_time].to_time).to eq(start_time)
      expect(attributes[:end_time].to_time).to eq(end_time)
    end
  end

  it 'should delete discount' do
    discount = create(:discount_all)
    delete discount_path(discount.code), headers: headers
    expect(response).to have_http_status(:success), response.body
    discount = Discount.find_by(code: discount.code)
    expect(discount).to be_nil, 'discount should be deleted'
  end

  def login!
    user = create(:superadmin)
    post user_session_path, params: { "user": {
      "username": user.username,
      "password": user.password
    } }
    @authorization = response.headers['Authorization']
  end

  def headers
    {
      'Authorization' => @authorization,
      'Content-Type' => 'application/json'
    }
  end
end
