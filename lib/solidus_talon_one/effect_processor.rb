module TalonOneSpree
  class EffectProcessor
    def initialize(order)
      @order = order
    end

    def call(method, response)
      if method == :update_customer_profile
        # A customer profile update currently doesn't belong to a session, therefore doesn't belong to an order, and so we should not process effects.
        #
        # This assumption may not hold forever, but at the moment it prevents us from really unexpected behaviour.
        return
      end
      @order.adjustments.destroy_all
      clear_free_items

      response.event.effects.each do |effect|
        method_name = "handle_#{effect.function}_effect"
        if respond_to? method_name
          send(*[method_name, *effect.args])
        end
      end

      @order.update_totals
    end

    def adjustments_by_name
      @adjustments_by_name ||= @order.adjustments.reduce({}) do |lookup, a|
        lookup.merge!(a.label => a)
      end
    end

    # TODO: process profileId and label
    def handle_addFreeItem_effect(profileId, sku, label)
      @order.line_items.create!(variant: Spree::Variant.find_by_sku(sku),
                                quantity: 1,
                                price: 0)
    end

    def handle_setDiscount_effect(label, discount)
      adj = adjustments_by_name[label]
      if adj
        adj.amount = -discount
      else
        adj = @order.adjustments.create(amount: -discount,
                                        label: label,
                                        order_id: @order.id)
        adjustments_by_name[label] = adj
      end
    end

    private

    # Clear free items before applying effects so that they are removed when a customer no longer qualifies
    def clear_free_items
      free_items = @order.line_items.select {|item| item.price == 0}
      @order.line_items.delete(*free_items)
    end
  end
end
