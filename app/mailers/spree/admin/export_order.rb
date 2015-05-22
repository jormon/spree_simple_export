class Spree::Admin::ExportOrder < ActionMailer::Base
  default from: "jordan@kulikulifoods.com"

  def export_orders_csv email, orders_dot_csv_contents
    attachments['orders.csv'] = orders_dot_csv_contents
    mail to: email,
         subject: "Spree Order Export",
         body: "Orders attached in orders.csv!"
  end
end
