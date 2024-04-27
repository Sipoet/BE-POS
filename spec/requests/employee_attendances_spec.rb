require 'swagger_helper'

RSpec.describe 'employee_attendances', type: :request do
  let(:user){create(:superadmin)}
  let(:'Authorization') { get_auth_token(user)}

  path '/employee_attendances' do

    # parameter name: 'Authorization', in: :header, type: :string, required: true
    parameter name: 'Content-Type', in: :header, type: :string, required: true

    get('list employee_attendances') do
      tags 'Employee Attendance'
      security [ bearer_auth: [] ]
      parameter name: 'search_text', in: :query, type: :string, required: false
      parameter name: 'page[page]', in: :query, type: :number, required: false
      parameter name: 'page[limit]', in: :query, type: :number, required: false
      parameter name: 'include', in: :query, type: :string, required: false
      parameter name: 'sort', in: :query, type: :string, required: false
      parameter name: 'filter[employee_id]', in: :query, type: :string, required: false
      parameter name: 'filter[date]', in: :query, type: :string, required: false
      let(:'Content-Type') { 'application/json' }

      response(200, 'successful') do
        let(:'page[page]'){1}
        let(:'page[limit]'){20}
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/employee_attendances/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    # parameter name: 'Authorization', in: :header, type: :string, required: true
    parameter name: 'Content-Type', in: :header, type: :string, required: true

    delete('delete employee_attendance') do
      tags 'Employee Attendance'
      security [ bearer_auth: [] ]
      response(200, 'successful') do
        let(:id) { create(:employee_attendance).id }
        let(:'Content-Type') { 'application/json' }
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/employee_attendances/mass_upload' do
    post('mass upload employee attendance from absence machine report') do
      tags 'Employee Attendance'
      security [ bearer_auth: [] ]
      consumes 'multipart/form-data'
      # parameter name: 'Authorization', in: :header, type: :string, required: true
      parameter name: 'Content-Type', in: :header, type: :string, required: true
      parameter name: 'file', in: :formData, type: :file, required: true
      response 201, 'successful' do
        let(:'Content-Type') { 'multipart/form-data' }
        let(:'file'){Rack::Test::UploadedFile.new("#{Rails.root}/spec/test_assets/attendance_example.xlsx",'r+')}

        run_test!(focus: true) do |response|
          expect(response.status).to eq(201)
        end
      end
    end
  end

  describe 'POST /mass_upload' do
    let(:file){Rack::Test::UploadedFile.new("#{Rails.root}/spec/test_assets/attendance_example.xlsx",'r+')}
    it 'saved' do
      employee = create(:active_employee, code:'employee1',name:'employee1')
      upload_attendance
      employee_attendances = EmployeeAttendance.where(employee_id: employee.id, date: Date.new(2024,4,13))
      expect(employee_attendances).to be_exists
      expect(employee_attendances.count).to eq(1)
      employee_attendance = employee_attendances.first
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,13,7,56))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,13,17,3))
      expect(employee_attendance.start_work).to eq('07:56')
      expect(employee_attendance.end_work).to eq('17:03')
      employee_attendances = EmployeeAttendance.where(employee_id: employee.id, date: Date.new(2024,4,15))
      expect(employee_attendances).to be_exists
      expect(employee_attendances.count).to eq(1)
      employee_attendance = employee_attendances.first
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,15,13,2))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,15,22,19))
      expect(employee_attendance.start_work).to eq('13:02')
      expect(employee_attendance.end_work).to eq('22:19')
      employee_attendances = EmployeeAttendance.where(employee_id: employee.id, date: Date.new(2024,4,17))
      expect(employee_attendances).not_to be_exists
    end

    it 'no saved if no end absence' do
      employee = create(:active_employee, code:'employee2',name:'employee2')
      employee2 = create(:active_employee, code:'employee3',name:'employee3')
      upload_attendance
      employee_attendances = EmployeeAttendance.where(employee_id: employee.id, date: Date.new(2024,4,17))
      expect(employee_attendances).not_to be_exists
      employee_attendances = EmployeeAttendance.where(employee_id: employee2.id, date: Date.new(2024,4,10))
      expect(employee_attendances).not_to be_exists
    end

    it 'support multiple range schedule' do
      employee = create(:active_employee, code:'employee1',name:'employee1')
      upload_attendance
      employee_attendances = EmployeeAttendance.where(employee_id: employee.id, date: Date.new(2024,4,1))
                                               .order(start_time: :asc)
      expect(employee_attendances).to be_exists
      expect(employee_attendances.count).to eq(2)
      employee_attendance = employee_attendances.first
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,1,10,57))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,1,15,3))
      expect(employee_attendance.start_work).to eq('10:57')
      expect(employee_attendance.end_work).to eq('15:03')
      employee_attendance = employee_attendances.last
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,1,17,54))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,1,23,56))
      expect(employee_attendance.start_work).to eq('17:54')
      expect(employee_attendance.end_work).to eq('23:56')
    end

    it 'offset begin and end work' do
      setting = Setting.create!(key_name:'attendance_minute_offset',value: {data:'60'}.to_json)
      employee = create(:active_employee, code:'employee2',name:'employee2')
      upload_attendance
      employee_attendances = EmployeeAttendance.where(employee_id: employee.id, date: Date.new(2024,4,14))
      expect(employee_attendances).to be_exists
      expect(employee_attendances.count).to eq(1)
      employee_attendance = employee_attendances.first
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,14,14,41))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,14,22,3))
      expect(employee_attendance.start_work).to eq('14:41')
      expect(employee_attendance.end_work).to eq('22:03')
      employee_attendances = EmployeeAttendance.where(employee_id: employee.id, date: Date.new(2024,4,16))
      expect(employee_attendances).to be_exists
      expect(employee_attendances.count).to eq(1)
      employee_attendance = employee_attendances.first
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,16,14,47))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,16,22,15))
      expect(employee_attendance.start_work).to eq('14:47')
      expect(employee_attendance.end_work).to eq('22:15')
      setting.update!(value: {data:'10'}.to_json)
      upload_attendance
      employee_attendances = EmployeeAttendance.where(employee_id: employee.id, date: Date.new(2024,4,14))
      expect(employee_attendances).to be_exists
      expect(employee_attendances.count).to eq(1)
      employee_attendance = employee_attendances.first
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,14,14,41))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,14,14,52))
      expect(employee_attendance.start_work).to eq('14:41')
      expect(employee_attendance.end_work).to eq('14:52')
    end

    it 'separator day' do
      Setting.create(key_name:'attendance_minute_offset',value: {data:'07:00'}.to_json)
      employee = create(:active_employee, code:'employee2',name:'employee2')
      upload_attendance
      employee_attendances = EmployeeAttendance.where(employee_id: employee.id, date: Date.new(2024,4,7))
                                               .order(start_time: :asc)
      expect(employee_attendances).to be_exists
      expect(employee_attendances.count).to eq(2)
      employee_attendance = employee_attendances.first
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,7,7,58))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,7,12,1))
      expect(employee_attendance.start_work).to eq('07:58')
      expect(employee_attendance.end_work).to eq('12:01')
      employee_attendance = employee_attendances.last
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,7,14,56))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,8,0,1))
      expect(employee_attendance.start_work).to eq('14:56')
      expect(employee_attendance.end_work).to eq('00:01')
      employee_attendances = EmployeeAttendance.where(employee_id: employee.id, date: Date.new(2024,4,9))
                                               .order(start_time: :asc)
      expect(employee_attendances).to be_exists
      expect(employee_attendances.count).to eq(2)
      employee_attendance = employee_attendances.first
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,9,8,0))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,9,12,1))
      expect(employee_attendance.start_work).to eq('08:00')
      expect(employee_attendance.end_work).to eq('12:01')
      employee_attendance = employee_attendances.last
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,9,15,1))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,10,5,0))
      expect(employee_attendance.start_work).to eq('15:01')
      expect(employee_attendance.end_work).to eq('05:00')
      employee_attendances = EmployeeAttendance.where(employee_id: employee.id, date: Date.new(2024,4,10))
                                               .order(start_time: :asc)
      expect(employee_attendances).to be_exists
      expect(employee_attendances.count).to eq(1)
      employee_attendance = employee_attendances.first
      expect(employee_attendance.start_time).to eq(Time.new(2024,4,10,14,55))
      expect(employee_attendance.end_time).to eq(Time.new(2024,4,10,22,17))
      expect(employee_attendance.start_work).to eq('14:55')
      expect(employee_attendance.end_work).to eq('22:17')
    end

    def upload_attendance
      post '/employee_attendances/mass_upload',params:{file: file}, headers:{'Content-Type'=>'multipart/form-data','Authorization'=> get_auth_token(user)}
    end
  end
end
