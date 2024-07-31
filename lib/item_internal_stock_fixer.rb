class ItemInternalStockFixer

  MINUS_TYPE=['keluar','remasuk','remasuk_konsi','keluar_konsi','transfer']

  def initialize(item)
    @item = item
    raise 'not item' unless @item.is_a?(Ipos::Item)
  end

  def run!(location)
    item_in_internals = Ipos::ItemInInternal.where(item: @item,
                                                   kodekantor: location)
                                            .order(tanggal: :asc)
                                            .to_a
    item_in_internals.each do |item_in_internal|
      item_in_internal.transfer = 0
      item_in_internal.keluar = 0
      item_in_internal.remasuk = 0
      item_in_internal.rekeluar = 0
      item_in_internal.remasuk_konsi = 0
      item_in_internal.rekeluar_konsi = 0
      item_in_internal.keluar_konsi = 0
      item_in_internal.sisa = item_in_internal.masuk
    end
    transactions =[]
    sale_items = Ipos::SaleItem.where(item: @item, sale: Ipos::ItemOutHeader.where(kantordari: location))
                                     .includes(:sale)
                                     .order(:'tbl_ikhd.tanggal' => :asc)
    sale_items.each do |sale_item|
      sale = sale_item.sale
      next if sale.tipe == 'KSRP'
      key = sale.tipe == 'RJ' ?  'rekeluar' : 'keluar'
      qty = sale_item.jumlah
      if @item.satuan != sale_item.satuan
        item_uom_qty = Ipos::ItemMeasurementQuantity.find_by(satuan:sale_item.satuan,kodeitem: sale_item.kodeitem)
        qty = qty * item_uom_qty.jumlahkonv
      end
      transactions << [sale.tanggal,key,qty]
    end
    item_transfer_details = Ipos::TransferItem.where(item: @item,transfer: Ipos::Transfer.where(kantordari: location))
                                     .includes(:transfer)
                                     .order('tbl_itrhd.tanggal' => :asc)
    item_transfer_details.each do |transfer_item|
      transfer = transfer_item.transfer
      qty = transfer_item.jumlah
      if @item.satuan != transfer_item.satuan
        item_uom_qty = Ipos::ItemMeasurementQuantity.find_by(satuan:transfer_item.satuan,kodeitem: transfer_item.kodeitem)
        qty = qty * item_uom_qty.jumlahkonv
      end
      transactions << [transfer_item.transfer.tanggal,'transfer',qty]
    end
    item_return_details = Ipos::PurchaseItem.where(item: @item, purchase: Ipos::ItemInHeader.where(kantortujuan: location))
                                     .includes(:purchase)
                                     .order(:'tbl_imhd.tanggal' => :asc)
    item_return_details.each do |item_out_detail|
      purchase = item_out_detail.purchase
      qty = item_out_detail.jumlah
      if @item.satuan != item_out_detail.satuan
        item_uom_qty = Ipos::ItemMeasurementQuantity.find_by(satuan:item_out_detail.satuan,
                                                             kodeitem: item_out_detail.kodeitem)
        qty = qty * item_uom_qty.jumlahkonv
      end
      if purchase.tipe == 'RB'
        transactions << [purchase.tanggal,'remasuk',qty]
      elsif purchase.tipe=='RKI'
        transactions << [purchase.tanggal,'remasuk_konsi',qty]
      end
    end
    opname_items = Ipos::ItemOpname.where(item: @item, kodekantor: location, jmlselisih: ...0)
    opname_items.each do |opname_item|
      qty = opname_item.jmlselisih.abs
      if @item.satuan != opname_item.satuan
        item_uom_qty = Ipos::ItemMeasurementQuantity.find_by(satuan:opname_item.satuan,
                                                             kodeitem: opname_item.kodeitem)
        qty = qty * item_uom_qty.jumlahkonv
      end
      transactions << [opname_item.tanggal,'keluar',qty]
    end
    insert_order_funct = if @item.hppsys == '1'
      lambda{|(date,key,qty)| insert_by_fifo(qty,key,item_in_internals,date)}
    else
      lambda{|(date,key,qty)|insert_by_lifo(qty,key,item_in_internals,date)}
    end
    transactions = transactions.sort_by{|row|row[0]}
    transactions.each(&insert_order_funct)
    item_in_internals.each do |item_in_internal|
      item_in_internal.save!
    end
  end

  private

  def insert_by_fifo(quantity,key,item_in_internals,date, is_turnaround: false)
    leftover_qty = quantity.dup
    total_rows = item_in_internals.length
    sisa_funct = if MINUS_TYPE.include?(key)
      ->(item_in_internal,qty){item_in_internal.sisa -= qty}
    else
      ->(item_in_internal,qty){item_in_internal.sisa += qty}
    end
    item_in_internals.each.with_index(1) do |item_in_internal, index|
      next if item_in_internal.sisa <=0
      next if item_in_internal.tanggal > date
      batas = MINUS_TYPE.include?(key) ? item_in_internal.sisa : item_in_internal.masuk - item_in_internal.sisa
      qty = [batas, leftover_qty].min
      item_in_internal.send("#{key}=", item_in_internal.send(key) + qty)
      sisa_funct.call(item_in_internal,qty)
      leftover_qty -= qty
      break if leftover_qty <= 0
      next if total_rows != index
      if is_turnaround
        sisa_funct.call(item_in_internal,leftover_qty)
        item_in_internal.send("#{key}=", item_in_internal.send(key) + leftover_qty)
      else
        insert_by_lifo(leftover_qty,key,item_in_internals.reverse,Date.new(9999,12,31),is_turnaround: true)
      end

    end
  end



  def insert_by_lifo(quantity,key,item_in_internals,date, is_turnaround: false)
    leftover_qty = quantity.dup
    total_rows = item_in_internals.length
    sisa_funct = if MINUS_TYPE.include?(key)
      ->(item_in_internal,qty){item_in_internal.sisa -= qty}
    else
      ->(item_in_internal,qty){item_in_internal.sisa += qty}
    end
    item_in_internals.reverse.each.with_index(1) do |item_in_internal, index|
      if item_in_internal.sisa >0 && item_in_internal.tanggal <= date
        batas = MINUS_TYPE.include?(key) ? item_in_internal.sisa : item_in_internal.masuk - item_in_internal.sisa
        qty = [batas, leftover_qty].min
        item_in_internal.send("#{key}=", item_in_internal.send(key) + qty)
        sisa_funct.call(item_in_internal,qty)
        leftover_qty -= qty
      end
      break if leftover_qty <= 0
      next if total_rows != index
      if is_turnaround
        sisa_funct.call(item_in_internal,leftover_qty)
        item_in_internal.send("#{key}=", item_in_internal.send(key) + leftover_qty)
      else
        insert_by_lifo(leftover_qty,key,item_in_internals.reverse,Date.new(9999,12,31),is_turnaround: true)
      end

    end
  end


end
