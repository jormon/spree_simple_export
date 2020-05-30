module SpreeSimpleExports
  module PromotionDecorator
    def export_code
      code || "promotion:#{id}"
    end
  end
end

Spree::Promotion.prepend(SpreeSimpleExports::PromotionDecorator)
