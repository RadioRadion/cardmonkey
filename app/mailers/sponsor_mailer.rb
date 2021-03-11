class SponsorMailer < ApplicationMailer
  def send_sponsor
    @user = params[:user]
    mail(to: @user.email, subject: "Reconfirmez votre addresse mail")
  end
end

# SponsorMailer.with(user: User.last).send_sponsor.deliver_now
