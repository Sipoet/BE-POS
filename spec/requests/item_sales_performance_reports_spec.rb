require 'rails_helper'

RSpec.describe "ItemSalesPerformanceReports", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/item_sales_performance_reports/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /supplier" do
    it "returns http success" do
      get "/item_sales_performance_reports/supplier"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /item_type" do
    it "returns http success" do
      get "/item_sales_performance_reports/item_type"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /brand" do
    it "returns http success" do
      get "/item_sales_performance_reports/brand"
      expect(response).to have_http_status(:success)
    end
  end

end
