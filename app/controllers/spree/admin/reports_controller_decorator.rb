Spree::Admin::ReportsController.class_eval do
  before_action :created_at_gt, only: [:export_orders]
  before_action :created_at_lt, only: [:export_orders]

  module SimpleExport
    def initialize
      Spree::Admin::ReportsController.add_available_report!(:export_orders)
      super
    end
  end
  prepend SimpleExport

  # load helper method to views & controller
  helper "spree/admin/export_orders"
  include Spree::Admin::ExportOrdersHelper

  def export_orders; end

  def background_export_orders
    async_params = {
      include_pii: params[:include_pii],
      created_at_gt_i: created_at_gt.to_time.to_i,
      created_at_lt_i: created_at_lt.to_time.to_i,
      store_id: params[:store_id],
      email: try_spree_current_user.try(:email)
    }

    raise "No email for signed in user!" if async_params[:email].blank?

    Spree::Admin::ExportOrderEmailerJob.perform_later async_params
    flash[:notice] = Spree.t(:email_you_shortly)
    redirect_to admin_reports_path
  end

  private
  def store_id
    params[:store_id].blank? ? Spree::Store.all.map(&:id) : params[:store_id]
  end

  def created_at_gt
    params[:created_at_gt] = if params[:created_at_gt].blank?
      Date.today.beginning_of_month
    else
      Date.parse(params[:created_at_gt])
    end
  end

  def created_at_lt
    params[:created_at_lt] = if params[:created_at_lt].blank?
      Date.today
    else
      Date.parse(params[:created_at_lt])
    end
  end
end

