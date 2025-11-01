require 'rails_helper'

RSpec.describe CashierSession, type: :model do
  context 'cashier session today' do
    before :each do
      Setting.set!('day_separator_at', '07:00')
      @first_march = CashierSession.create!(date: Date.new(2025, 3, 1))
      @second_march = CashierSession.create!(date: Date.new(2025, 3, 2))
      @third_march = CashierSession.create!(date: Date.new(2025, 3, 3))
    end

    it 'hour before separator set to yesterday session' do
      Timecop.travel(DateTime.new(2025, 3, 2, 0, 0, 0))
      expect(CashierSession.today_session).to eq(@first_march)

      Timecop.travel(DateTime.new(2025, 3, 2, 5, 30, 0))
      expect(CashierSession.today_session).to eq(@first_march)

      Timecop.travel(DateTime.new(2025, 3, 3, 4, 15, 0))
      expect(CashierSession.today_session).to eq(@second_march)

      Timecop.travel(DateTime.new(2025, 3, 3, 2, 57, 0))
      expect(CashierSession.today_session).to eq(@second_march)
    end

    it 'hour after separator set to today session' do
      Timecop.travel(DateTime.new(2025, 3, 1, 7, 0, 0))
      expect(CashierSession.today_session).to eq(@first_march)

      Timecop.travel(DateTime.new(2025, 3, 1, 22, 0, 0))
      expect(CashierSession.today_session).to eq(@first_march)

      Timecop.travel(DateTime.new(2025, 3, 2, 23, 59, 0))
      expect(CashierSession.today_session).to eq(@second_march)

      Timecop.travel(DateTime.new(2025, 3, 2, 15, 30, 0))
      expect(CashierSession.today_session).to eq(@second_march)

      Timecop.travel(DateTime.new(2025, 3, 3, 15, 30, 0))
      expect(CashierSession.today_session).to eq(@third_march)
    end
  end
end
