module Spree
  OrdersController.class_eval do
    before_action :edit, :talon_before_order_edit

    def talon_before_order_edit
      if current_order

        current_order.talon_coupon = params[:talon_coupon]
        current_order.talon_notifier.track_coupon params[:talon_coupon]

        current_order.talon_referral = params[:talon_referral]
        current_order.talon_notifier.track_referral params[:talon_referral]

        if current_order.changed?
          current_order.save
        end
      end
    end
  end
end
