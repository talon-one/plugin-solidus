Deface::Override.new(:virtual_path => 'spree/orders/edit',
  :name => 'referral_field',
  :insert_after => "div.links",
  :text => <<-SNIP
<div style='text-align:right;margin-top:70px'>
  <label><b>Talon.One Referral Code:</b> 
    <input type='text' id='talon_referral' name='talon_referral' value='<%= @order.talon_referral || "" %>'>
    <% if @order.talon_referral && @order.talon_notifier.rejected_referral? %>
      <strong>Referral code invalid!</strong>
    <% end %>
  </label> 
  <button onclick=\"location.href='/cart?talon_referral='+document.getElementById('talon_referral').value;return false\">Redeem</button>
  <style>#order_referral_code{display:none}</style>
</div>
<% if params[:talon_debug] %>
<div style='margin-top:50px;margin-bottom:50px'>
  <pre id='talon-debug'><%=  @talon_plugin.debug_log.map{|e| JSON.pretty_generate e}.join("\n\n") %></pre>
</div>
<% end %>
SNIP
)
