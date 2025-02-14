class PurchaseOrder::UpdatePriceService < ApplicationService
  ROUND_TYPE_LIST = ['normal','ceil','floor','mark']

  def execute_service
    extract_params
    purchase_order = Ipos::PurchaseOrder.find(@code)
    raise RecordNotFound.new(@code,PurchaseOrder.model_name.human) if purchase_order.nil?
    ApplicationRecord.transaction do
      update_po_items_price!(purchase_order)
    end
    render_json({message:'sukses update harga'})
  end

  private

  def update_po_items_price!(purchase_order)
    purchase_order.purchase_order_items
                  .includes(:item)
                  .each{|line| update_item_price!(purchase_order, line)}
  end

  def update_item_price!(purchase_order,purchase_item)
    item = purchase_item.item
    fraction_header_cost = purchase_item.total * (purchase_order.biayalain + purchase_order.potnomfaktur) / purchase_order.subtotal
    hpp = ((purchase_item.total + fraction_header_cost)/purchase_item.jumlah).round(2)
    sell_price = hpp + (hpp * @margin/ 100)
    sell_price = send("round_type_#{@round_type}",sell_price)

    Rails.logger.debug "#{purchase_item.notransaksi} |item #{item.kodeitem} |harga beli sbelum diskon #{purchase_item.harga} |fraction_header_cost #{fraction_header_cost.round(2)} |HPP #{hpp} |margin #{@margin}% |harga jual #{sell_price}"
    item.update!(
      hargajual1: sell_price,
      hargapokok: hpp,
      )
  end

  def round_type_normal(number)
    number.round(@round_precission)
  end

  def round_type_ceil(number)
    number.ceil(@round_precission)
  end

  def round_type_floor(number)
    number.floor(@round_precission)
  end

  def round_type_mark(number)
    num_floor = number.floor(@round_precission)
    if (number - num_floor) > @mark_separator
      number.floor(@round_precission) + @mark_upper
    else
      number.floor(@round_precission) + @mark_lower
    end
  end

  def extract_params
    @margin = params.fetch(:margin,1).to_f
    @round_type = params.fetch(:round_type, 'normal')
    raise 'invalid round type' unless ROUND_TYPE_LIST.include?(@round_type)
    @round_precission = params.fetch(:round_precission,0).to_i
    @mark_upper = params.fetch(:mark_upper,0).to_f
    @mark_lower = params.fetch(:mark_lower,0).to_f
    @mark_separator = params.fetch(:mark_separator,0).to_i
    @code = CGI.unescape(params[:code])
  end
end
