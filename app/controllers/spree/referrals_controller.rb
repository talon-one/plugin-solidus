module Spree
  class ReferralsController < Spree::BaseController
    before_action :authorize

    def create
      profile_id = "user_#{spree_current_user.id}"
      campaign_id = params[:talon_referral][:campaign_id].to_i
      friend_email = params[:talon_referral][:friend]
      send_invite = false
      friend = nil

      if friend_email && !friend_email.empty?
        friend = Spree::User.find_by_email(friend_email)
        if !friend
          friend = Spree::User.new(email: friend_email)
          friend.save(validate: false)
          send_invite = true
        end
      end

      client = TalonOne::Integration::Client.new
      begin
        # ensure customer profile exists
        client.update_customer_profile profile_id, {}
        if friend
          # ensure friend profile exists
          friend_id = "user_#{friend.id}"
          client.update_customer_profile friend_id, {}
          @referral = client.create_referral_code(campaign_id, profile_id, friend_id:friend_id)
        else
          @referral = client.create_referral_code(campaign_id, profile_id)
        end
        if send_invite
          friend.invite!(spree_current_user)
          flash[:notice] = "Invited #{friend.email} with code #{@referral.code}"
        elsif friend
          flash[:notice] = "Created new referral code #{@referral.code} for #{friend.email}"
        else
          flash[:notice] = "Your new referral code is #{@referral.code}"
        end
      rescue Exception => err
        flash[:error] = "An error occured while creating the referral code #{err}"
      end

      redirect_to('/account')
    end

    def authorize
      if nil == spree_current_user
        raise CanCan::AccessDenied
      end
    end
  end
end
