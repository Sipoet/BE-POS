require 'rails_helper'

RSpec.describe "CashTransactionReports", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/cash_transaction_reports/index"
      expect(response).to have_http_status(:success)
    end
  end

end
