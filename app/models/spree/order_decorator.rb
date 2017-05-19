
module Spree
  Order.class_eval do
    attr_accessor :talon_coupon
    attr_accessor :talon_referral

    register_update_hook :talon_one_update_hook

    state_machine.after_transition do |order, transition|
      order.talon_notifier.track_transition transition
    end

    def talon_notifier
      @talon_notifier ||= TalonOneSpree::Notifier.new(self)
    end

    def talon_one_update_hook
      puts "\n\n====> [talon.one] Order update hook\n\n"
      talon_notifier.track_order
      true
    end
  end
end
