class PurchaseReportSerializer
  include JSONAPI::Serializer
  attributes  :code,
              :supplier_code,
              :purchase_date,
              :due_date,
              :purchase_item_total,
              :purchase_subtotal,
              :header_discount_amount,
              :purchase_other_cost,
              :purchase_grand_total,
              :order_date,
              :shipping_date,
              :order_item_total,
              :order_grand_total,
              :return_item_total,
              :return_amount_total,
              :grandtotal,
              :paid_amount,
              :last_paid_date,
              :debt_amount,
              :status


  belongs_to :supplier, serializer: Ipos::SupplierSerializer, set_id: :supplier_code, id_method_name: :supplier_code

end
