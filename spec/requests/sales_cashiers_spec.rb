require 'rails_helper'

RSpec.describe "SalesCashiers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/sales_cashiers/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/sales_cashiers/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/sales_cashiers/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/sales_cashiers/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/sales_cashiers/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
