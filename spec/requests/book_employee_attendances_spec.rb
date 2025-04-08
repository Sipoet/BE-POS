require 'rails_helper'

RSpec.describe "BookEmployeeAttendances", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/book_employee_attendances/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/book_employee_attendances/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/book_employee_attendances/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/book_employee_attendances/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/book_employee_attendances/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
