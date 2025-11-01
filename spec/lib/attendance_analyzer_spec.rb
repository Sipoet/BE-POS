
require 'rails_helper'

RSpec.describe AttendanceAnalyzer, type: :model do
  let(:payroll) { create(:payroll) }
  let(:employee) { create(:active_employee, payroll: payroll) }
  let(:start_date){Date.new(2025,9,26)}
  let(:end_date){Date.new(2025,10,25)}

  describe '#analyze' do
    before :each do
      create_schedule(employee.role)
    end
    context 'sick leave' do
      it 'should identify sick leave only in range' do
        EmployeeLeave.create!(employee: employee,leave_type: :sick_leave, date: Date.new(2025,9,29))
        EmployeeLeave.create!(employee: employee,leave_type: :sick_leave, date: Date.new(2025,8,20))
        result = default_params_analyze
        expect(result.sick_leave).to eq(1)
      end

      it 'should identify no sick leave if no sick leave submitted' do
        result = default_params_analyze
        expect(result.sick_leave).to eq(0)
      end

    end

    context 'known leave' do
      it 'should identify only in range' do
        EmployeeLeave.create!(employee: employee,leave_type: :unpaid_leave, date: Date.new(2025,9,29))
        EmployeeLeave.create!(employee: employee,leave_type: :unpaid_leave, date: Date.new(2025,8,20))
        result = default_params_analyze
        expect(result.known_absence).to eq(1)
      end

      it 'should identify no leave if no known leave except sick leave submitted' do
        result = default_params_analyze
        expect(result.known_absence).to eq(0)
      end
    end

    context 'unknown leave' do
      it 'should identify only in range' do
        (start_date..end_date).each do |date|
          create_default_attendance(date) if date != Date.new(2025,9,29)
        end
        result = default_params_analyze
        expect(result.unknown_absence).to eq(1)
      end

      it 'should identify no unknown leave' do
        sick_date = Date.new(2025,9,30)
        leave_date = Date.new(2025,9,29)
        (start_date..end_date).each do |date|
          create_default_attendance(date) unless [sick_date,leave_date].include?(date)
        end
        EmployeeLeave.create!(employee: employee,leave_type: :unpaid_leave, date: leave_date)
        EmployeeLeave.create!(employee: employee,leave_type: :sick_leave, date: sick_date)
        result = default_params_analyze
        expect(result.unknown_absence).to eq(0)
      end
    end
    context 'total scheduled work days' do
      it 'sohuld be 28 if day off every 2 week' do
        EmployeeDayOff.create!(employee: employee, day_of_week: 7, active_week: :even_week)
        result = default_params_analyze
        expect(result.total_day).to eq(28)
      end

      it 'sohuld be 30' do
        result = default_params_analyze
        expect(result.total_day).to eq(30)
      end

      it 'should be 29 if period more than 1 month' do
        result = AttendanceAnalyzer.new(
          payroll: employee.payroll,
          employee: employee,
          start_date: start_date,
          end_date: start_date + 2.month
        ).analyze
        expect(result.total_day).to eq(29)
      end

    end

    context 'total employee work days' do
      it 'sohuld be 28 if day off every 2 week' do
        sick_date = Date.new(2025,9,30)
        leave_date = Date.new(2025,9,29)
        (start_date..end_date).each do |date|
          create_default_attendance(date) unless [sick_date,leave_date].include?(date)
        end
        EmployeeLeave.create!(employee: employee,leave_type: :unpaid_leave, date: leave_date)
        EmployeeLeave.create!(employee: employee,leave_type: :sick_leave, date: sick_date)
        result = default_params_analyze
        expect(result.work_days).to eq(28)
      end

      it 'sohuld be 30' do
        (start_date..end_date).each do |date|
          create_default_attendance(date)
        end
        result = default_params_analyze
        expect(result.work_days).to eq(30)
      end
    end
  end

  describe '#scheduled_work?' do
    before :each do
      create_schedule(employee.role)
    end
    it 'should not flag scheduled if employee not working anymore' do
      employee.update!(end_working_date: Date.new(2025,9,28))
      analyzer = AttendanceAnalyzer.new(
        payroll: employee.payroll,
        employee: employee,
        start_date: start_date,
        end_date: end_date)
      analyzer.analyze
      expect(analyzer.send(:scheduled_work?,Date.new(2025,9,28))).to be true
      expect(analyzer.send(:scheduled_work?,Date.new(2025,9,29))).to be false
    end

    context 'employee day off should not flag scheduled' do
      it 'on all week' do
        EmployeeDayOff.create!(employee: employee, day_of_week: 7, active_week: :all_week)
        analyzer = AttendanceAnalyzer.new(
          payroll: employee.payroll,
          employee: employee,
          start_date: start_date,
          end_date: end_date)
        analyzer.analyze
        expect(analyzer.send(:scheduled_work?,Date.new(2025,9,28))).to be false
        expect(analyzer.send(:scheduled_work?,Date.new(2025,9,29))).to be true
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,5))).to be false
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,6))).to be true
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,12))).to be false
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,13))).to be true
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,19))).to be false
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,20))).to be true
      end
      it 'on odd week' do
        EmployeeDayOff.create!(employee: employee, day_of_week: 7, active_week: :odd_week)
        analyzer = AttendanceAnalyzer.new(
          payroll: employee.payroll,
          employee: employee,
          start_date: start_date,
          end_date: end_date)
        analyzer.analyze
        expect(analyzer.send(:scheduled_work?,Date.new(2025,9,28))).to be false
        expect(analyzer.send(:scheduled_work?,Date.new(2025,9,29))).to be true
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,5))).to be true
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,6))).to be true
      end

      it 'on even week' do
        EmployeeDayOff.create!(employee: employee, day_of_week: 7, active_week: :even_week)
        analyzer = AttendanceAnalyzer.new(
          payroll: employee.payroll,
          employee: employee,
          start_date: start_date,
          end_date: end_date)
        analyzer.analyze
        expect(analyzer.send(:scheduled_work?,Date.new(2025,9,28))).to be true
        expect(analyzer.send(:scheduled_work?,Date.new(2025,9,29))).to be true
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,5))).to be false
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,6))).to be true
      end

      it 'on first week' do
        EmployeeDayOff.create!(employee: employee, day_of_week: 7, active_week: :first_week_of_month)
        analyzer = AttendanceAnalyzer.new(
          payroll: employee.payroll,
          employee: employee,
          start_date: start_date,
          end_date: end_date)
        analyzer.analyze
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,5))).to be false
        expect(analyzer.send(:scheduled_work?,Date.new(2025,10,6))).to be true
      end

      it 'on last week' do
        EmployeeDayOff.create!(employee: employee, day_of_week: 7, active_week: :last_week_of_month)
        analyzer = AttendanceAnalyzer.new(
          payroll: employee.payroll,
          employee: employee,
          start_date: start_date,
          end_date: end_date)
        analyzer.analyze
        expect(analyzer.send(:scheduled_work?,Date.new(2025,9,28))).to be false
        expect(analyzer.send(:scheduled_work?,Date.new(2025,9,29))).to be true
      end
    end

    it 'should not flag scheduled if national holiday' do
      Holiday.create(date: Date.new(2025,9,28),description:'national holiday')
      analyzer = AttendanceAnalyzer.new(
        payroll: employee.payroll,
        employee: employee,
        start_date: start_date,
        end_date: end_date)
      analyzer.analyze
      expect(analyzer.send(:scheduled_work?,Date.new(2025,9,28))).to be false
      expect(analyzer.send(:scheduled_work?,Date.new(2025,9,29))).to be true
    end

    it 'should not flag scheduled if religion holiday' do
      Holiday.create(date: Date.new(2025,9,28),description:'religion holiday', religion: :catholic)
      Holiday.create(date: Date.new(2025,9,29),description:'religion holiday', religion: :hindu)
      employee.update!(religion: :catholic)
      analyzer = AttendanceAnalyzer.new(
        payroll: employee.payroll,
        employee: employee,
        start_date: start_date,
        end_date: end_date)
      analyzer.analyze
      expect(analyzer.send(:scheduled_work?,Date.new(2025,9,28))).to be false
      expect(analyzer.send(:scheduled_work?,Date.new(2025,9,29))).to be true
    end
    context 'trade work day' do
      before :each do
        EmployeeDayOff.create!(employee: employee, day_of_week: 7, active_week: :all_week)
        EmployeeLeave.create!(employee: employee,leave_type: :change_day, date: Date.new(2025,9,29),change_date: Date.new(2025,9,28),change_shift: 1)
        @analyzer = AttendanceAnalyzer.new(
          payroll: employee.payroll,
          employee: employee,
          start_date: start_date,
          end_date: end_date)
        @analyzer.analyze
      end
      it 'should flag scheduled if destination' do
        expect(@analyzer.send(:scheduled_work?,Date.new(2025,9,28))).to be true
      end

      it 'should not flag scheduled if old/source day' do
        expect(@analyzer.send(:scheduled_work?,Date.new(2025,9,29))).to be false
      end
    end
  end

  def create_default_attendance(date)
    create(:employee_attendance, employee: employee,date: date)
  end

  def create_schedule(role)
    (1..7).each do |dow|
      RoleWorkSchedule.create!(group_name: 'normal',begin_work: '08:00',end_work: '15:00',shift: 1,day_of_week: dow,begin_active_at: start_date, role: role, end_active_at: RoleWorkSchedule::LAST_END_DATE)
      RoleWorkSchedule.create!(group_name: 'normal',begin_work: '15:00',end_work: '22:00',shift: 2,day_of_week: dow,begin_active_at: start_date, role: role, end_active_at: RoleWorkSchedule::LAST_END_DATE)
    end
  end

  # analyze with default parameters
  def default_params_analyze
    AttendanceAnalyzer.new(
      payroll: employee.payroll,
      employee: employee,
      start_date: start_date,
      end_date: end_date
    ).analyze
  end
end
