class CustomerGroupDiscount < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:customer_group_code, :link, attribute_key:'customer_groups.grup'),
    datatable_column(self,:period_type, :string),
    datatable_column(self,:discount_percentage, :decimal),
    datatable_column(self,:start_active_date, :date),
    datatable_column(self,:end_active_date, :date),
    datatable_column(self,:level, :integer),
    datatable_column(self,:variable1, :decimal),
    datatable_column(self,:variable2, :decimal),
    datatable_column(self,:variable3, :decimal),
    datatable_column(self,:variable4, :decimal),
    datatable_column(self,:variable5, :decimal),
    datatable_column(self,:variable6, :decimal),
    datatable_column(self,:variable7, :decimal),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ]
  enum :period_type, {
    active_period: 0,
    day_of_month: 1,
    day_of_week: 2,
    week_of_month: 3
  }

  validates :discount_percentage, presence: true
  validates :period_type, presence: true
  validates :start_active_date, presence: true
  validates :end_active_date, presence: true
  validates :level, presence: true
  validates :variable1, numericality: {integer: true}, allow_nil: true
  validates :variable2, numericality: {integer: true}, allow_nil: true
  validates :variable3, numericality: {integer: true}, allow_nil: true
  validates :variable4, numericality: {integer: true}, allow_nil: true
  validates :variable5, numericality: {integer: true}, allow_nil: true
  validates :variable6, numericality: {integer: true}, allow_nil: true
  validates :variable7, numericality: {integer: true}, allow_nil: true
  validate :end_active_date_should_valid
  validate :period_type_setting

  belongs_to :customer_group, class_name: 'Ipos::CustomerGroup', foreign_key: :customer_group_code, primary_key: :kgrup

  scope :active_date,->(date){where("? BETWEEN start_active_date AND end_active_date",date)}

  private

  def end_active_date_should_valid
    if end_active_date.present? && end_active_date < start_active_date
      errors.add(:end_active_date,:greater_than, count: start_active_date.strftime('%d/%m/%y'))
    end
  end

  def period_type_setting
    if day_of_month?
      if variable1.blank?
        errors.add(:variable1, :blank)
      elsif variable1 > 31 || variable1 < -1
        errors.add(:variable1, :invalid)
      end
      if variable2.blank?
        errors.add(:variable2, :blank)
      elsif variable2 > 31 || variable2 < -1
        errors.add(:variable2, :invalid)
      end
    elsif day_of_week? || week_of_month?
      min_num = day_of_week? ? 1 : -1
      max_num = day_of_week? ? 7 : 5
      if variable1.blank?
        errors.add(:variable1, :blank)
      elsif !variable1.between?(min_num, max_num)
        errors.add(:variable1, :invalid)
      end
      if variable2.present? && !variable2.between?(min_num, max_num)
        errors.add(:variable2, :invalid)
      end
      if variable3.present? && !variable3.between?(min_num, max_num)
        errors.add(:variable3, :invalid)
      end
      if variable4.present? && !variable4.between?(min_num, max_num)
        errors.add(:variable4, :invalid)
      end
      if variable5.present? && !variable5.between?(min_num, max_num)
        errors.add(:variable5, :invalid)
      end
      if variable6.present? && !variable6.between?(min_num, max_num)
        errors.add(:variable6, :invalid)
      end
      if variable7.present? && !variable7.between?(min_num, max_num)
        errors.add(:variable7, :invalid)
      end
    end
  end

end
