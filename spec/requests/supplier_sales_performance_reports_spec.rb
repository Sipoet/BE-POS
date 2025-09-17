require 'rails_helper'

RSpec.describe "SupplierSalesPerformanceReports", type: :request do
  describe "GET /compare" do
    it "returns http success" do
      get "/supplier_sales_performance_reports/compare"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /group_by_brand" do
    it "returns http success" do
      get "/supplier_sales_performance_reports/group_by_brand"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /group_by_item_type" do
    it "returns http success" do
      get "/supplier_sales_performance_reports/group_by_item_type"
      expect(response).to have_http_status(:success)
    end
  end

end
