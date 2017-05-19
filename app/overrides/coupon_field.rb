Deface::Override.new(:virtual_path => 'spree/orders/edit',
  :name => 'coupon_field',
  :insert_after => "div.links",
  :text => <<-SNIP
<div style='text-align:right;margin-top:70px'>
  <label><b>Talon.One Coupon:</b> 
    <input type='text' id='talon_coupon' name='talon_coupon' value='<%= @order.talon_coupon || "" %>'>
    <% if @order.talon_coupon && @order.talon_notifier.rejected_coupon? %>
      <strong>Coupon invalid!</strong>
    <% end %>
  </label> 
  <button onclick=\"location.href='/cart?talon_coupon='+document.getElementById('talon_coupon').value;return false\">Redeem</button>
  <style>#order_coupon_code{display:none}</style>
</div>
<% if params[:talon_debug] %>
<div style='margin-top:50px;margin-bottom:50px'>
  <pre id='talon-debug'><%=  @talon_plugin.debug_log.map{|e| JSON.pretty_generate e}.join("\n\n") %></pre>
</div>
<% end %>
SNIP
)
