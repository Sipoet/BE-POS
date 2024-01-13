require 'rails_helper'

RSpec.describe "ItemSalesPercentageReports", type: :request do

  before :each do
    login!
  end

  describe "GET /index" do
    it "should success" do
      get item_sales_percentage_reports_path, headers: headers
      expect(response).to have_http_status(:success)
    end
    context 'filter' do
      before :each do
        sale = Sale.create(notransaksi: 'test1')
        item = create(:item)
        item_sale = ItemSale.create(notransaksi:'test1',
                                    kodeitem: item.kodeitem,
                                    jumlah:1,
                                    harga:10,
                                    total:10,
                                    subtotal:10)

      end
      it "supplier" do
        get item_sales_percentage_reports_path,params:{suppliers:['S013']}, headers: headers
        expect(response).to have_http_status(:success)
      end

      it "item" do
        get item_sales_percentage_reports_path,params:{items:['23010001']}, headers: headers
        expect(response).to have_http_status(:success)
      end

      it "brand" do
        get item_sales_percentage_reports_path,params:{brands:['WWW']}, headers: headers
        expect(response).to have_http_status(:success)
      end

      it "item_type" do
        get item_sales_percentage_reports_path,params:{item_types:['001-OBW']}, headers: headers
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /columns" do
    it "should success" do
      get columns_item_sales_percentage_reports_path, headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  private

  def login!
    user = create(:superadmin)
    post user_session_path, params: {"user":{
      "username": user.username,
      "password": user.password
    }}
    @authorization = response.headers['Authorization']
  end

  def headers
    {
      'Authorization' => @authorization,
      'Content-Type' => 'application/json'
    }
  end
end
