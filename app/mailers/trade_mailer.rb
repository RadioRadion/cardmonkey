class TradeMailer < ApplicationMailer
  def new_trade(trade)
    @trade = trade
    @recipient = trade.user_invit
    @sender = trade.user
    @trade_cards = trade.user_cards.includes(card_version: [:card, :extension])

    return unless @recipient.email_notifications?

    mail(
      to: @recipient.email,
      subject: "#{@sender.username} vous propose un échange"
    )
  end

  def trade_modified(trade, modifier)
    @trade = trade
    @modifier = modifier
    @recipient = trade.other_user(modifier)
    @trade_cards = trade.user_cards.includes(card_version: [:card, :extension])

    return unless @recipient.email_notifications?

    mail(
      to: @recipient.email,
      subject: "#{@modifier.username} a modifié la proposition d'échange"
    )
  end

  def trade_accepted(trade, accepter)
    @trade = trade
    @accepter = accepter
    @recipient = trade.other_user(accepter)

    return unless @recipient.email_notifications?

    mail(
      to: @recipient.email,
      subject: "#{@accepter.username} a accepté votre échange !"
    )
  end

  def trade_completed(trade)
    @trade = trade
    @user = trade.user
    @user_invit = trade.user_invit

    emails = []
    emails << @user.email if @user.email_notifications?
    emails << @user_invit.email if @user_invit.email_notifications?

    return if emails.empty?

    mail(
      to: emails,
      subject: "Échange terminé - Merci d'utiliser Godeck !"
    )
  end

  def new_match(user, matches)
    @user = user
    @matches = matches
    @match_count = matches.count

    return unless @user.email_notifications?

    mail(
      to: @user.email,
      subject: "#{@match_count} nouveau#{'x' if @match_count > 1} match#{'s' if @match_count > 1} trouvé#{'s' if @match_count > 1} !"
    )
  end
end
