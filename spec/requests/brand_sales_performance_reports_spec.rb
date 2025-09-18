require 'rails_helper'

RSpec.describe "BrandSalesPerformanceReports", type: :request do
  describe "GET /compare" do
    it "returns http success" do
      get "/brand_sales_performance_reports/compare"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /group_by_supplier" do
    it "returns http success" do
      get "/brand_sales_performance_reports/group_by_supplier"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /group_by_item_type" do
    it "returns http success" do
      get "/brand_sales_performance_reports/group_by_item_type"
      expect(response).to have_http_status(:success)
    end
  end

end
