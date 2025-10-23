class Payslip::PayService < ApplicationService

  def execute_service
    extract_params
    payslips = find_payslips
    if payslips.blank?
      render_json({message:'payslip tidak valid'},{status: :conflict})
      return
    end
    ApplicationRecord.transaction do
      cash_out = create_cash_out_from_payslips(payslips)
      create_account_journal(cash_out)
      send_payslip_via_email(payslips) if @is_notify

      payslips.update_all(payment_time: @paid_at, status: :paid)
    end
    render_json({message:'Sukses Simpan Pembayaran'})
  end

  private

  def send_payslip_via_email(payslips)
    payslip_ids = payslips.pluck(:id)
    payslip_ids.each do |payslip_id|
      PayslipMailer.with(payslip_id: payslip_id)
                   .employee_payslip
                   .deliver_later
    end
  end

  def find_payslips
    query = Payslip.where(start_date: @start_date,end_date: @end_date)
           .where.not(status: :paid)
    if @employee_ids.present?
      query = query.where(employee_id: @employee_ids)
    end
    query
  end

  def extract_params
    permitted_params = params.permit(:paid_at,:description,:location,:cash_account, :start_date,:is_notify, :end_date, employee_ids:[])
    @is_notify = permitted_params[:is_notify].to_s == '1'
    @employee_ids = permitted_params[:employee_ids] || []
    @start_date = Date.parse(permitted_params[:start_date]) rescue nil
    @end_date = Date.parse(permitted_params[:end_date]) rescue nil

    @payslip_ids = permitted_params[:payslip_ids]
    @paid_at = DateTime.parse(permitted_params[:paid_at])
    @cash_account = Ipos::Account.find(permitted_params[:cash_account])
    @description = permitted_params[:description]
    @location = Ipos::Location.find(permitted_params[:location])
  end

  def create_cash_out_from_payslips(payslips)
    total = payslips.sum(:nett_salary)
    office_code = @location&.id
    date_stamp = Date.today.strftime('%m%y')
    rand_numb =Array.new(4){SecureRandom.random_number(9)}.join
    cash_out = Ipos::CashOut.build(
      notransaksi: "#{rand_numb}/PAYSLIP/#{office_code}/#{date_stamp}",
      tanggal: @paid_at,
      kodekantor: office_code,
      matauang: 'IDR',
      rate: 1,
      keterangan: @description,
      kodeacc: @cash_account.id,
      updated_at: DateTime.now,
      jumlah: total,
      subtotal: total,
      bc_trf_sts: false,
      user1: 'ADMIN',
    )
    payslips.includes(:employee).each_with_index do |payslip, index|
      employee = payslip.employee
      cash_out.cash_details.build(
        iddetail: "#{cash_out.notransaksi}-#{cash_out.kodekantor}-#{salary_account.id}-#{index+1}",
        nobaris: index + 1,
        notransaksi: cash_out.notransaksi,
        kodeacc: salary_account.id,
        matauang: 'IDR',
        rate: 1,
        jumlah: payslip.nett_salary,
        dateupd: DateTime.now,
        keterangan: "Gaji #{employee.name}(#{employee.id}). no slip: #{payslip.id}"
      )
    end
    cash_out.save!
    cash_out
  end

  def create_account_journal(cash_out)
    Ipos::AccountJournal.create!(
      iddetail: "#{cash_out.notransaksi}-#{cash_out.kodeacc}-1",
      nourut: 1,
      jenis:'Jurnal',
      keterangan: cash_out.keterangan,
      matauang: cash_out.matauang,
      rate: cash_out.rate,
      jumlah: cash_out.subtotal,
      posisi:'K',
      debet: 0,
      kredit: cash_out.subtotal,
      tipeinput:'R',
      notransaksi: cash_out.notransaksi,
      tanggal: cash_out.tanggal,
      kodeacc: cash_out.kodeacc,
      kantor: cash_out.kodekantor,
      modul: 'KAS'
    )
    cash_out.cash_details.each_with_index do |cash_detail,index|
      Ipos::AccountJournal.create!(
        iddetail: "#{cash_detail.notransaksi}-#{cash_detail.kodeacc}-#{index + 2}",
        nourut: index + 2,
        jenis:'Jurnal',
        keterangan: cash_detail.keterangan,
        matauang: cash_detail.matauang,
        rate: cash_detail.rate,
        jumlah: cash_detail.jumlah,
        posisi:'D',
        debet: cash_detail.jumlah,
        kredit: 0,
        tipeinput:'R',
        notransaksi: cash_out.notransaksi,
        tanggal: cash_out.tanggal,
        kodeacc: cash_detail.kodeacc,
        kantor: cash_out.kodekantor,
        modul: 'KAS'
      )
    end
  end

  def salary_account
    @salary_account ||= Ipos::Account.find_by("namaacc ilike '%gaji pegawai%' OR namaacc ilike '%gaji karyawan%'")
  end

end
