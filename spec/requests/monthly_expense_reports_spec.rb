require 'rails_helper'

RSpec.describe 'MonthlyExpenseReports', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/monthly_expense_reports/index'
      expect(response).to have_http_status(:success)
    end
  end
end
