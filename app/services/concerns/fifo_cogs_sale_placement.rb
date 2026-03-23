class FifoCogsSalePlacement
  attr_reader :item

  def initialize(new_item)
    @item = new_item
  end

  def place!
    fifo_stocks = find_fifo_stocks
    sale_items = find_item_outs
    item_stock = fifo_stocks.shift
    if item_stock.nil?
      sale_items.update_all(hppdasar: item.hargapokok) if item.hargapokok.zero?
      return
    end
    ApplicationRecord.transaction do
      sale_items.each do |sale_item|
        if item_stock.nil?
          sale_item.update!(hppdasar: item.hargapokok)
          break
        end
        sale_qty = convert_to_base_uom(qty: sale_item.jumlah, uom: sale_item.satuan)
        purchase_prices = []
        while sale_qty.positive? && item_stock.present?
          if sale_qty < item_stock.quantity
            item_stock.quantity -= sale_qty
            purchase_prices << StockPrice.new(price: item_stock.price, quantity: sale_qty)
            sale_qty = 0
          else
            sale_qty -= item_stock.quantity
            purchase_prices << StockPrice.new(price: item_stock.price, quantity: item_stock.quantity)
            item_stock.quantity = 0
          end
          item_stock = fifo_stocks.shift if item_stock.quantity.zero?
        end
        purchase_prices << StockPrice.new(price: item.hargapokok, quantity: sale_qty) if sale_qty.positive?
        cogs = calculate_cogs(purchase_prices)
        sale_item.update!(hppdasar: cogs)
      end
    end
  end

  private

  def find_item_outs
    Ipos::SaleItem.where(kodeitem: item.code).joins(:sale).order(Ipos::ItemOutHeader.arel_table[:tanggal].asc)
  end

  def find_fifo_stocks
    fifo_stocks = Ipos::BeginningBalance.where(kodeitem: item.code).pluck(:jumlah, :satuan, :total)
    fifo_stocks += Ipos::PurchaseItem.where(kodeitem: item.code).joins(:purchase).order(Ipos::ItemInHeader.arel_table[:tanggal].asc).pluck(
      :jumlah, :satuan, :total
    )
    fifo_stocks.map do |(quantity, uom, total)|
      price = total.to_d / quantity.to_d
      StockPrice.new(price: convert_to_base_uom(qty: price, uom: uom),
                     quantity: convert_to_base_uom(qty: quantity, uom: uom))
    end
  end

  def calculate_cogs(purchase_prices)
    purchase_prices.sum { |x| x.quantity.to_d * x.price.to_d } / purchase_prices.sum { |x| x.quantity.to_d }
  end

  def convert_to_base_uom(qty:, uom:)
    if uom == @item.satuan
      qty
    else
      conversion = Ipos::ItemMeasurementQuantity.find_by(kodeitem: item.kodeitem,
                                                         satuan: uom)&.jumlahkonv || 0
      qty * conversion
    end
  end

  class StockPrice
    attr_reader :price
    attr_accessor :quantity

    def initialize(quantity:, price:)
      @quantity = quantity
      @price = price
    end
  end
end
