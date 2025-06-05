class ConsignmentIn::UpdatePriceService < ApplicationService

  ROUND_TYPE_LIST = ['normal','ceil','floor','mark']
  def execute_service
    extract_params
    consignment_in = Ipos::ConsignmentIn.find(@code)
    raise RecordNotFound.new(@code,Ipos::ConsignmentIn.model_name.human) if consignment_in.nil?
    ApplicationRecord.transaction do
      update_po_items_price!(consignment_in)
    end
    render_json({message:'sukses update harga'})
  end

  private

  def update_po_items_price!(consignment_in)
    consignment_in.purchase_items
                  .includes(:item)
                  .each{|line| update_item_price!(consignment_in, line)}
  end

  def update_item_price!(consignment_in,purchase_item)
    item = purchase_item.item
    fraction_header_cost = purchase_item.total * (consignment_in.biayalain + consignment_in.potnomfaktur) / consignment_in.subtotal
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
    @round_precission = round_precission_based_mark_separator(@mark_separator)
    num_floor = number.floor(@round_precission)
    if (number - num_floor) > @mark_separator
      number.floor(@round_precission) + @mark_upper
    else
      number.floor(@round_precission) + @mark_lower
    end
  end

  def extract_params
    permitted_params = params.permit(:margin,:round_type,:mark_upper,:mark_lower,:mark_separator,:code)
    @margin = permitted_params.fetch(:margin,1).to_f
    @round_type = permitted_params.fetch(:round_type, 'normal')
    raise 'invalid round type' unless ROUND_TYPE_LIST.include?(@round_type)
    @mark_upper = permitted_params.fetch(:mark_upper,0).to_f
    @mark_lower = permitted_params.fetch(:mark_lower,0).to_f
    @mark_separator = permitted_params.fetch(:mark_separator,0).to_i
    @code = permitted_params[:code]
  end

  def round_precission_based_mark_separator(mark_separator)
    Math.log10(mark_separator).ceil * -1
  end

end
