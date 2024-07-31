class WorkScheduleFinder

  def initialize(role_id)
    @role_id = role_id
  end

  def shift_based_attendances(employee_attendances)
    work_schedules = work_schedules_based_attendances(employee_attendances)
    work_schedules.first.try(:shift)
  end

  def shift_based_arr_range_date(arr_range_date)
    work_schedules = find_estimate_work_schedules(arr_range_date)
    work_schedules.first.try(:shift)
  end

  def work_schedules_based_attendances(employee_attendances)
    arr_range_date = employee_attendances.map{|line|line.start_time..(line.end_time)}
    find_estimate_work_schedules(arr_range_date)
  end

  def work_schedules_from_shift(date, shift)
    date_work_schedules = work_schedules_based_date(date)
    date_work_schedules[shift]
  end

  def find_estimate_work_schedules(arr_range_date)
    find_role_schedules if @work_schedules.blank?
    return [] if arr_range_date.empty?
    date = arr_range_date.first.try(:first).try(:to_date)
    date_work_schedules = work_schedules_based_date(date)
    probably_shift = 1
    same_hour = 0
    date_work_schedules.each do |shift, work_schedules|
      work_schedules = work_schedules.sort_by{|work_schedule| schedule_of(date,work_schedule.begin_work)}
      hour = 0
      same_schedule = 0
      arr_range_date.each.with_index(0) do |range, index|
        work_schedule = work_schedules[index]
        break if work_schedule.blank?
        schedule_begin_at = schedule_of(date,work_schedule.begin_work)
        schedule_end_at = schedule_of(date,work_schedule.end_work)
        if schedule_begin_at >= range.first && schedule_end_at <= range.last
          same_schedule += 1
        end
        hour += difference_hour([schedule_begin_at,range.first].max, [schedule_end_at,range.last].min)
      end
      if same_schedule == arr_range_date.length
        return work_schedules
      end
      if hour > same_hour
        same_hour = hour
        probably_shift = shift
      end
    end
    date_work_schedules[probably_shift]
  end

  private
  def work_schedules_based_date(date)
    day_work_schedules = @work_schedules[date.cwday]
    return [] if day_work_schedules.nil?
    date_work_schedules = day_work_schedules.select{|work_schedule|date.between?(work_schedule.begin_active_at,work_schedule.end_active_at)}
    level = date_work_schedules.map(&:level).uniq.max
    date_work_schedules.select{|work_schedule| work_schedule.level == level}
                       .group_by(&:shift)
  end



  def find_role_schedules
    @work_schedules = RoleWorkSchedule.where(role_id: @role_id)
                                       .group_by(&:day_of_week)
  end

  def schedule_of(date, time)
    Time.parse("#{date.iso8601} #{time}")
  end

  def difference_hour(time_a, time_b)
    BigDecimal(((time_a.to_time - time_b.to_time)/1.hour).round(1).abs.to_s)
  end
end
