class SpreeSimpleExport::OrderExporter
  def initialize created_at_lt_i, created_at_gt_i, store_id, include_pii
    @include_pii = include_pii

    @variant_name_map = _variant_name_map.freeze
    @columns = _columns.freeze

    @order_scope = Spree::Order.complete
    unless @store_id.blank?
      @order_scope = @order_scope.where(store_id: store_id)
    end
    @order_scope = @order_scope.where \
      created_at: [(Time.at created_at_gt_i)..(Time.at created_at_lt_i)]
  end


  def to_csv
    csv_data = []
    @order_scope.find_each do |order|
      csv_data += order_to_line_item_arr(order).map(&:to_csv)
    end
    csv_data_s = ([@columns.join(",") + "\n"] + csv_data).flatten.join
  end

  def order_to_line_item_arr(order)
    order.line_items.map do |li|
      data = [
        order.number,
        order.completed_at,
        # placeholder for bio data
        order.state,
        order.shipment_state,
        order.bill_address.try(:city),
        order.bill_address.try(:state).try(:abbr),
        order.bill_address.try(:zipcode),
        order.ship_address.try(:city),
        order.ship_address.try(:state).try(:abbr),
        order.ship_address.try(:zipcode),
        order.item_total,
        order.ship_total,
        order.tax_total,
        order.shipment_adjustments.sum(:amount).to_f,
        order.adjustments.sum(:amount).to_f,
        order.total,
        li.quantity,
        li.price,
        li.additional_tax_total,
        li.variant_id,
        li.variant.sku,
        order.shipments.first.number,
        @variant_name_map[li.variant_id],

        order.promotions.map(&:code).join(','),
      ]

      # insert some extra fields if we want biographical info
      if @include_pii
        [
          order.email,
          order.bill_address.last_name,
          order.bill_address.first_name
        ].each do |value|
          data.insert 2, value
        end
      end

      # hand back the complete data set
      data
    end
  end

  private
  def variant_name variant_id
    @variant_name_map[variant_id]
  end

  def _variant_name_map
    Spree::Variant.includes(:product).each_with_object({}) do |variant, obj|
      obj[variant.id] = variant.product.slug
    end
  end

  def _columns
    cols = %w[number date_time first_name last_name email state shipment_state billing_city billing_state billing_zip shipping_city shipping_state shipping_zip item_total ship_total tax_total shipment_adjustments_total order_adjustments_total total li_quantity li_price li_addition_tax_total li_variant_id li_sku li_slug li_shipment promotion_codes]
    unless @include_pii
      cols.delete 'first_name'
      cols.delete 'last_name'
      cols.delete 'email'
    end
    cols
  end
end
