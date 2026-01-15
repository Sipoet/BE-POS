class Ipos::Transfer::CreateService < ApplicationService
  def execute_service
    transfer = Transfer.new
    if record_save?(transfer)
      render_json(TransferSerializer.new(transfer, fields: @fields), { status: :created })
    else
      render_error_record(transfer)
    end
  end

  def record_save?(transfer)
    ApplicationRecord.transaction do
      build_attribute(transfer)
      build_transfer_items(transfer)
      return false unless valid_transfer?(transfer)

      transfer.save!
      transfer.transfer_items.each do |transfer_item|
        update_internal_table!(transfer_item, transfer)
      end
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def valid_transfer?(transfer)
    transfer.transfer_items.each do |transfer_item|
      return false unless enough_stock?(transfer_item)
    end
    true
  end

  def enough_stock?(transfer_item)
    stock_left = Ipos::ItemInInternal.where(kodeitem: transfer_item.kodeitem,
                                            kodekantor: transfer_item.kantordari).sum(:sisa)
    stock_left >= transfer_item.jumlah
  end

  def build_transfer_items(transfer)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:transfer_items)
                             .permit(data: [:type, :id, { attributes: %i[
                                       kodeitem
                                       jumlah
                                       satuan
                                       jmlkonversi
                                       detinfo
                                       nobaris
                                       dateupd
                                     ] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    permitted_params[:data].each do |line_params|
      transfer_item = transfer.transfer_items.build(line_params[:attributes])
      transfer_item.iddetail = "#{transfer.notransaksi}-#{from}-#{rand_number(18)}-#{transfer_item.nobaris}"
    end
  end

  def rand_number(num_digit)
    SecureRandom.rand(10.pow(num_digit - 1)..(10.pow(num_digit)))
  end

  def create_journal!(transfer, total_cogs:)
    Ipos::AccountJournal.create!(
      iddetail: "#{transfer.notransaksi}-#{rand_number(18)}-#{transfer.source_office.try(:kodeacc)}",
      nourut: 2,
      tipeinput: 'R',
      notransaksi: transfer.notransaksi,
      tanggal: transfer.tanggal,
      kodeacc: transfer.source_office.try(:kodeacc),
      jenis: 'Jurnal',
      matauang: 'IDR',
      rate: 1,
      jumlah: total_cogs,
      posisi: 'D',
      debet: total_cogs,
      kredit: 0,
      kantor: transfer.kodekantor,
      modul: 'PRS',
      keterangan: transfer.keterangan
    )
    Ipos::AccountJournal.create!(
      iddetail: "#{transfer.notransaksi}-#{rand_number(18)}-#{transfer.destination_office.try(:kodeacc)}",
      nourut: 1,
      tipeinput: 'R',
      notransaksi: transfer.notransaksi,
      tanggal: transfer.tanggal,
      kodeacc: transfer.source_office.try(:kodeacc),
      jenis: 'Jurnal',
      matauang: 'IDR',
      rate: 1,
      jumlah: total_cogs,
      posisi: 'K',
      debet: 0,
      kredit: total_cogs,
      kantor: transfer.kodekantor,
      modul: 'PRS',
      keterangan: transfer.keterangan
    )
  end

  def create_log!(transfer)
    timing = transfer.tanggal.strftime('%d%m%Y%H%M%S%3N')
    Ipos::ActivityLog.create(
      object: 'TRANSFER',
      value: 'TR',
      description: 'Tambah Data Transfer Item',
      iddetail: '',
      notransaksi: transfer.notransaksi,
      CMD: 'INSERT',
      user1: 'ADMIN',
      shift: '',
      kodekantor: transfer.kodekantor,
      dateupd: transfer.tanggal,
      compname: '',
      id: "TRX/#{timing}",
      nama_app: 'IPOS5U',
      versi_app: '5.0.9.3'
    )
  end

  def create_item_out!(transfer_item:, item_in_internal:, transfer:, qty:)
    iddetailtrs = "#{transfer_item.notransaksi}-#{transfer.kodekantor}-#{rand_number(18)}-2"
    Ipos::ItemOutInternal.create!(
      iddetail: "#{iddetailtrs}-trs",
      iddetailtrs: iddetailtrs,
      iddetailim: item_in_internal.iddetail,
      kodekantor: item_in_internal.kodekantor,
      notransaksi: transfer_item.notransaksi,
      tanggal: transfer.tanggal,
      tipe: TIPE,
      kodeitem: transfer_item.kodeitem,
      jumlahdasar: qty,
      satuandasar: item_in_internal.satuandasar,
      hargadasar: item_in_internal.hargadasar,
      jmlretur: 0,
      jmlkotagih: 0
    )
  end

  def create_item_internal!(item_in:, transfer_item:, transfer:, qty: 0)
    iddetailtrs = "#{transfer_item.notransaksi}-#{transfer.kodekantor}-#{rand_number(18)}-1"
    Ipos::ItemInInternal.create!(
      notransaksi: transfer_item.notransaksi,
      iddetail: "#{iddetailtrs}-trs",
      iddetailtrs: iddetailtrs,
      kodekantor: transfer.kantortujuan,
      tanggal: transfer.tanggal,
      tgl_trs: transfer.tanggal,
      tipe: TIPE,
      matauang: 'IDR',
      rate: 1,
      kodeitem: transfer_item.kodeitem,
      jumlahdasar: qty,
      satuandasar: item_in.satuandasar,
      hargadasar: item_in.hargadasar,
      masuk: qty,
      keluar: 0,
      remasuk: 0,
      rekeluar: 0,
      transfer: 0,
      sisa: qty,
      keluar_konsi: 0,
      remasuk_konsi: 0,
      rekeluar_konsi: 0,
      sisa_konsi: 0,
      flagavg: 0,
      ori_id_trf: transfer_item.iddetail
    )
  end

  def update_internal_table!(transfer_item, transfer)
    stock_left = transfer_item.jumlah
    total_cogs = 0
    item_in_internals = Ipos::ItemInInternal.where(kodeitem: transfer_item.kodeitem, kodekantor: transfer.kantordari)
                                            .where('sisa > 0')
                                            .order(tanggal: :asc)
    item_in_internals.each do |item_in|
      stock = [stock_left, item_in.sisa].min
      stock_left -= stock
      item_in.sisa -= stock
      item_in.transfer += stock
      item_in.save!
      total_cogs += item_in.hargadasar * stock
      item_in_internal = create_item_internal!(item_in: item_in, transfer_item: transfer_item, transfer: transfer,
                                               qty: stock)
      create_item_out!(transfer_item: transfer_item, transfer: transfer, qty: stock, item_in_internal: item_in_internal)
      break if stock_left <= 0
    end
    create_journal!(transfer, total_cogs: total_cogs)
    create_log!(transfer)
  end

  TIPE = 'TR'.freeze
  def build_attribute(transfer)
    table_definition = Datatable::DefinitionExtractor.new(Transfer)
    allowed_columns = table_definition.column_names
    @fields = { transfer: allowed_columns }
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(allowed_columns)
    transfer.attributes = permitted_params
    transfer.tipe = TIPE
    transfer.acc_persediaan = transfer.office.try(:kodeacc)
    transfer.notransaksi = create_code_for(transfer.tipe, location: transfer.kodekantor)
  end

  def create_code_for(trid, location: 'GDG')
    code_formatter = Ipos::FormatTransaction.find_by(trid: trid, kantor: location)
    if code_formatter.resetid == 'YM' && Date.today.strftime('%m%y') != code_formatter.lastgen.strftime('%m%y')
      code_formatter.nomor = 1
    elsif code_formatter.resetid == 'YY' && Date.today.strftime('%y') != code_formatter.lastgen.strftime('%y')
      code_formatter.nomor = 1
    else
      code_formatter.nomor += 1
    end
    code_formatter.lastgen = Time.now

    slot = []
    4.times do |index|
      format_symbol = code_formatter.send("slot#{index + 1}")
      case format_symbol
      when '[CNT]'
        slot << code_formatter.nomor.to_s.rjust(code_formatter.numdgt, '0')
      when '[DEPT]'
        slot << location
      when '[BLNTHN]'
        slot << Date.today.strftime('%m%y')
      when nil
        slot.pop
        break
      else
        slot << format_symbol
      end
      begin
        slot << code_formatter.send("sep#{index + 1}")
      rescue StandardError
        nil
      end
    end
    code_formatter.notransaksi = slot.compact.join
    code_formatter.save!
    code_formatter.notransaksi
  end
end
