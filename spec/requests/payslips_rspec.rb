require 'rails_helper'

RSpec.describe 'Payslips', type: :request do
  let(:user) { create(:admin) }
  let(:superadmin) { create(:superadmin) }
  let(:default_filter) { { start_date: Date.new(2025, 6, 26), end_date: Date.new(2025, 7, 25) } }
  context 'CRUD' do
    describe 'GET /reports' do
      it 'should success' do
        @headers = header_by_user(superadmin)
        get report_payslips_path, headers: @headers, params: { filter: default_filter }
        expect(response).to have_http_status(:success)
      end

      it 'should table column done right' do
        gp = PayrollType.create!(name: 'Gaji Pokok', initial: 'GP', order: 1)
        tj = PayrollType.create!(name: 'Tunjangan', initial: 'TJ', order: 2)
        @headers = header_by_user(superadmin)
        get report_payslips_path, headers: @headers, params: { filter: default_filter }
        expect(response).to have_http_status(:success)
        response_body = JSON.parse(response.body)
        table_columns = response_body.dig('meta', 'table_columns')
        expect(table_columns).not_to be_nil
        expect(table_columns.length).to eq(20)
        employee_column = table_columns.first
        expect(employee_column['name']).to eq('employee')
        expect(employee_column['humanize_name']).to eq('Nama Karyawan')
        expect(employee_column['type']).to eq('model')
        gp_column = table_columns[13]
        tj_column = table_columns[14]
        expect(gp_column['name']).to eq(gp.order.to_s)
        expect(gp_column['humanize_name']).to eq(gp.name)
        expect(gp_column['type']).to eq('money')
        expect(tj_column['name']).to eq(tj.order.to_s)
        expect(tj_column['humanize_name']).to eq(tj.name)
        expect(tj_column['type']).to eq('money')
      end
    end
  end

  def header_by_user(user)
    post user_session_path, params: { "user": {
      "username": user.username,
      "password": user.password
    } }
    authorization = response.headers['Authorization']
    {
      'Authorization' => authorization,
      'Content-Type' => 'application/json'
    }
  end
end
