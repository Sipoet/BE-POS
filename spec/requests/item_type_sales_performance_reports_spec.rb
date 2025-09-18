require 'rails_helper'

RSpec.describe "ItemTypeSalesPerformanceReports", type: :request do
  describe "GET /compare" do
    it "returns http success" do
      get "/item_type_sales_performance_reports/compare"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /group_by_supplier" do
    it "returns http success" do
      get "/item_type_sales_performance_reports/group_by_supplier"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /group_by_brand" do
    it "returns http success" do
      get "/item_type_sales_performance_reports/group_by_brand"
      expect(response).to have_http_status(:success)
    end
  end

end
