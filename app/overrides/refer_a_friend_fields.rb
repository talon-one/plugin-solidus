Deface::Override.new(:virtual_path => 'spree/users/show',
  :name => 'refer_a_friend_fields',
  :insert_after => "div.account-my-orders",
  :text => <<-SNIP
<div>
  <h3>My Referrals</h3>
  <br /><br />
  <% referrals = TalonOneSpree.get_referrals(@user) %>
  <% if referrals.length == 0 %>
    <p>You have not created any referral codes yet.</p>
  <% else %>
    <table>
    <tr>
      <th>Code</th>
      <th>Campaign</th>
      <th>Friend</th>
      <th>Usage</th>
      <th>State</th>
    </tr>
    <% referrals.map do |referral| %>
    <tr>
      <td><%= referral["code"] %></td>
      <td><%= referral["campaign"]["name"] %></td>
      <td><%= (referral["friend"] && referral["friend"].email) || "-" %></td>
      <td><%= referral["usageCounter"] %>/<%= if referral["usageLimit"] > 0 then referral["usageLimit"] else '∞' end %></td>
      <td><%= referral["campaign"]["state"] %></td>
    </tr>
    <% end %>
    </table>
  <% end %>

  <br /><br />
  <h4>Create a new Talon.One Referral Code</h4>
  <% active_campaigns = TalonOneSpree.get_campaigns.select{|c| c["state"] == "enabled"} %>
  <% if active_campaigns.length == 0 %>
    <p>There are no referral campaigns running.</p>
  <% else %>
  <%= form_for :talon_referral, url: url_for(controller: "referrals", action: "create") do |form| %>
    <label>On campaign
    <%= form.select :campaign_id, (active_campaigns.map {|c| [c["name"], c["id"]]}) %>
    </label>
    <br/><br/>
    <label>For a friend? <%= form.text_field "friend" %></label>
    <br/><br/>
    <%= form.submit "Create referral code" %>
  <% end %>
  <% end %>
</div>
SNIP
)
