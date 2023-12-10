require "test_helper"

class DiscountsControllerTest < ActionDispatch::IntegrationTest

  setup do
    login!
  end

  test "should get index" do
    get discounts_url, xhr: true, headers: headers
    assert_response :success
  end


  test "should display discount" do
    discount = discounts(:discount_all)
    get discount_url(discount.code), xhr: true, headers: headers
    assert_response :success
    result = JSON.parse(@response.body, symbolize_names: true)
    data = result[:data]
    assert_equal(discount.id.to_s, data[:id])
    assert_equal('discount', data[:type])
    attributes = data[:attributes]
    assert_equal(discount.code, attributes[:code])
    assert_equal(discount.supplier_code, attributes[:supplier_code])
    assert_equal(discount.brand_name, attributes[:brand_name])
    assert_equal(discount.item_code, attributes[:item_code])
    assert_equal(discount.item_type, attributes[:item_type])
    assert_equal(discount.discount1, attributes[:discount1])
    assert_equal(discount.discount2, attributes[:discount2])
    assert_equal(discount.discount3, attributes[:discount3])
    assert_equal(discount.discount4, attributes[:discount4])
    assert_equal(discount.start_time, attributes[:start_time].to_datetime)
    assert_equal(discount.end_time, attributes[:end_time].to_datetime)
  end

  test "should create discount" do
    discount_code = 'diskon-test'
    start_time = DateTime.new(2023,2,23)
    end_time = DateTime.new(2999,12,31,23,59,59)
    post discounts_url, xhr: true, headers: headers, params:{discount:{
      code: discount_code,
      start_time: start_time.iso8601,
      end_time: end_time.iso8601,
      item_code: 'item_code',
      supplier_code: 'supplier_code',
      item_type: 'item_type',
      brand_name: 'brand_name',
      discount1: 15,
      discount2: 25,
      discount3: 35,
      discount4: 45,
    }}.to_json
    assert_response :success

    discount = Discount.find_by(code: discount_code)
    result = JSON.parse(@response.body, symbolize_names: true)
    data = result[:data]
    assert_equal(discount.id.to_s, data[:id])
    assert_equal('discount', data[:type])
    attributes = data[:attributes]
    assert_equal(discount_code, attributes[:code])
    assert_equal('supplier_code', attributes[:supplier_code])
    assert_equal('brand_name', attributes[:brand_name])
    assert_equal('item_code', attributes[:item_code])
    assert_equal('item_type', attributes[:item_type])
    assert_equal(15, attributes[:discount1])
    assert_equal(25, attributes[:discount2])
    assert_equal(35, attributes[:discount3])
    assert_equal(45, attributes[:discount4])
    assert_equal(start_time, attributes[:start_time].to_datetime)
    assert_equal(end_time, attributes[:end_time].to_datetime)
  end

  test "should update discount" do
    start_time = DateTime.new(2023,5,23)
    end_time = DateTime.new(2999,10,01,23,59,59)
    discount = discounts(:discount_all)
    old_discount_code = discount.code
    patch discount_url(old_discount_code), xhr: true, headers: headers, params:{discount:{
      code: 'changed-code',
      start_time: start_time.iso8601,
      end_time: end_time.iso8601,
      item_code: 'item_code',
      supplier_code: 'supplier_code',
      item_type: 'item_type',
      brand_name: 'brand_name',
      discount1: 50,
      discount2: 40,
      discount3: 30,
      discount4: 20,
    }}.to_json
    assert_response :success
    result = JSON.parse(@response.body, symbolize_names: true)
    data = result[:data]
    assert_equal(discount.id.to_s, data[:id])
    assert_equal('discount', data[:type])
    attributes = data[:attributes]
    assert_equal(old_discount_code, attributes[:code], 'code shouldnt changed')
    assert_equal('supplier_code', attributes[:supplier_code])
    assert_equal('brand_name', attributes[:brand_name])
    assert_equal('item_code', attributes[:item_code])
    assert_equal('item_type', attributes[:item_type])
    assert_equal(50, attributes[:discount1])
    assert_equal(40, attributes[:discount2])
    assert_equal(30, attributes[:discount3])
    assert_equal(20, attributes[:discount4])
    assert_equal(start_time, attributes[:start_time].to_datetime)
    assert_equal(end_time, attributes[:end_time].to_datetime)
  end

  test "should delete discount" do
    discount = discounts(:discount_all)
    delete discount_url(discount.code), xhr: true, headers: headers
    assert_response :success
    result = JSON.parse(@response.body, symbolize_names: true)
    assert_equal('sukses dihapus', result[:message])
    discount = Discount.find_by(code: discount.code)
    assert_nil(discount, 'discount should be deleted')
  end

  def login!
    user = users(:superadmin)
    user.password_confirmation = user.encrypted_password
    user.password = user.encrypted_password
    user.save!
    post user_session_path, xhr: true, params: {"user":{
      "username": user.username,
      "password": user.password
    }}
    @authorization = @response.headers['Authorization']
  end

  def headers
    {
      'Authorization' => @authorization,
      'Content-Type' => 'application/json'
    }
  end
end
