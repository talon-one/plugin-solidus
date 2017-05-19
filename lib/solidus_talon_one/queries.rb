
require 'talon_one'

module TalonOneSpree
  def self.get_campaigns(app_id=ENV["TALONONE_APP_ID"], client=TalonOne::Management::Client.new)
      url = "/v1/applications/#{app_id}/campaigns"
      client.get(url)["data"]
  end

  # get_referrals collects all referral codes created by this user in all
  # campaigns, returned as an array of {campaign,referral} hashes.
  def self.get_referrals(user, app_id=ENV["TALONONE_APP_ID"], client=TalonOne::Management::Client.new)
    TalonOneSpree.get_campaigns(app_id, client).flat_map do |campaign|
      url = "/v1/applications/#{app_id}/campaigns/#{campaign["id"]}/referrals?advocate=user_#{user.id}"
      client.get(url)["data"].map do |referral|
        if referral["friendProfileIntegrationId"] && !referral["friendProfileIntegrationId"].empty? then
          friend_user_id = referral["friendProfileIntegrationId"].split("_").last.to_i
          referral.update("friend" => Spree::User.find(friend_user_id))
        end
        referral.update("campaign" => campaign)
      end
    end
  end
end
