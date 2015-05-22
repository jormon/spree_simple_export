class Spree::Admin::ExportOrderEmailerJob
  include SuckerPunch::Job

  def perform(args)
    # args has: email, created_at_gt, created_at_lt, store_id, include_pii
    puts args.inspect
    ActiveRecord::Base.connection_pool.with_connection do
      exporter = SpreeSimpleExport::OrderExporter.new \
        args[:created_at_lt_i],
        args[:created_at_gt_i],
        args[:store_id],
        args[:include_pii]

      Spree::Admin::ExportOrder.export_orders_csv(
        args[:email], exporter.to_csv
      ).deliver
    end
  end
end
