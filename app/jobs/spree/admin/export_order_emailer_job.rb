module Spree::Admin
  class ExportOrderEmailerJob < ActiveJob::Base
    def perform(args)
      # args has: email, created_at_gt, created_at_lt, store_id, include_pii
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
