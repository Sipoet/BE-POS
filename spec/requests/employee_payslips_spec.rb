require 'rails_helper'

RSpec.describe "EmployeePayslips", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/employee_payslips/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /generate_payslip" do
    it "returns http success" do
      get "/employee_payslips/generate_payslip"
      expect(response).to have_http_status(:success)
    end
  end

end
