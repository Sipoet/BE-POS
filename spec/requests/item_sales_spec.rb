require 'rails_helper'

RSpec.describe 'ItemSales', type: :request do
  describe 'GET /transaction_report' do
    before :each do
      login!
    end

    context 'returns http success group key' do
      it 'brand' do
        get transaction_report_item_sales_path, params: { group_key: 'brand' }, headers: headers
        expect(response).to have_http_status(:success)
      end

      it 'supplier' do
        get transaction_report_item_sales_path, params: { group_key: 'supplier' }, headers: headers
        expect(response).to have_http_status(:success)
      end

      it 'item_type' do
        get transaction_report_item_sales_path, params: { group_key: 'item_type' }, headers: headers
        expect(response).to have_http_status(:success)
      end
    end
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
