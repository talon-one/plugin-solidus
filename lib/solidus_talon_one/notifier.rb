require 'talon_one'

module TalonOneSpree
  class Notifier
    def self.transition_observers
      @transition_handlers ||= {
        "address" => :track_addresses,
        "delivery" => :track_shipments,
        "payment" => :track_payments,
        "confirm" => :track_confirmation,
      }
    end

    def self.transition_observers=(new_handlers)
      @transition_handlers = new_handlers
    end

    def track_transition(transition)
      method = Notifier.transition_observers[transition.from]
      send(method) if method
      true
    end

    def initialize(order)
      @order = order
      @debug_log = []
    end

    def debug_log
      @debug_log
    end

    def call(method, *args)
      begin
        res = client.send(method, *args)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        puts "\n\n<<<<<<<<< Can't connect to Talon.One: #{e}\n\n"
        @debug_log << {:method => method, :args => args, :success => false, :exception => e}
      else
        @debug_log << {:method => method, :args => args, :success => true, :response => res.instance_variable_get(:@raw) }
        if @order
          TalonOneSpree::EffectProcessor.new(@order).call(method, res)
        end
        @rejected_coupon ||= res.event.rejected_coupon?
        @rejected_referral ||= res.event.rejected_referral?
      end
    end

    def rejected_coupon?
      @rejected_coupon
    end

    def rejected_referral?
      @rejected_referral
    end

    def track_order
      session_details = {}

      if @order.changed.include? "state"
        session_details[:state] = normalized_state
      elsif normalized_state == "closed"
        # order was already completed and isn't changing state now, return early
        return
      end

      if @order.changed.include?("item_total")
        session_details[:total] = @order.item_total.to_f
      end

      if !(@order.changed & ["item_total", "item_count"]).empty?
        session_details[:cartItems] = cart_items
      end

      session_details.compact!
      if !session_details.empty?
        if profile_id
          session_details[:profileId] = profile_id
        end
        call(:update_customer_session, @order.number, add_profile_id(session_details))
      end
    end

    def track_coupon(coupon)
      if coupon && !coupon.empty?
        call(:update_customer_session, @order.number, add_profile_id({:coupon => coupon}))
      end
    end

    def track_referral(referral)
      if referral && !referral.empty?
        call(:update_customer_session, @order.number, add_profile_id({:referral => referral}))
      end
    end

    def track_addresses
      attributes = {}

      ["Billing", "Shipping"].each do |prefix|
        a = @order.send("#{prefix.downcase}_address")
        attributes.update({
          "#{prefix}Name" => "#{a.firstname} #{a.lastname}",
          "#{prefix}Address1" => a.address1,
          "#{prefix}Address2" => a.address2,
          "#{prefix}City" => a.city,
          "#{prefix}PostalCode" => a.zipcode,
          "#{prefix}Address4" => a.state_name,
          "#{prefix}Address3" => a.company,
          "#{prefix}Country" => a.country.iso,
        })
      end

      attributes.compact!

      if !attributes.empty?
        call(:update_customer_session, @order.number, add_profile_id({:attributes => attributes}))

        if profile_id
          attributes["Name"] = attributes["BillingName"]
          attributes["Phone"] = @order.billing_address.phone if @order.billing_address.try(:phone)
          attributes["SignupDate"] = @order.user.created_at if @order.user
          attributes["Email"] = @order.user.email if @order.user
          call(:update_customer_profile, profile_id, {:attributes => attributes})
        end
      end
    end

    def track_shipments
      call :update_customer_session, @order.number, :attributes => {
        "ShippingMethod" => @order.shipments.first.shipping_method.name,
        "ShippingCost" => @order.shipment_total.to_f
      }
    end

    def track_payments
      details = { :attributes => { "PaymentMethod" => @order.payments.first.payment_method.name } }
      call(:update_customer_session, @order.number, add_profile_id(details))
      if profile_id
        call(:update_customer_profile, profile_id, details)
      end
    end

    def track_confirmation
      call(:update_customer_session, @order.number, add_profile_id({:state => normalized_state})) if normalized_state
    end

    protected
    def profile_id
      if @order.user_id
        "user_#{@order.user_id}"
      elsif @order.email
        URI.escape "guest!#{@order.email}"
      end
    end

    def add_profile_id(params)
      if !profile_id
        params
      else
        {:profileId => profile_id}.update(params)
      end
    end

    def client
      @client ||= TalonOne::Integration::Client.new
    end

    def normalized_state
      if @order.state.to_s == "complete"
        "closed"
      end
    end

    def cart_items
      @cart_items ||= @order.line_items.select{|item| item.quantity > 0}.map do |item|
        {
          quantity: item.quantity,
          price: item.price.to_f,
          category: item.product.taxons.map{|t|t.name}.join(","),
          name: item.name,
          sku: item.sku
        }.compact
      end
    end
  end
end
