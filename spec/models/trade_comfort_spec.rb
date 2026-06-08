require "rails_helper"

RSpec.describe "Trade comforts" do
  describe "Trade#can_be_modified_by? (anti-oscillation)" do
    let(:a) { create(:user) }
    let(:b) { create(:user) }

    it "blocks the last modifier from modifying again until the partner responds" do
      trade = create(:trade, :modified, user: a, user_invit: b, last_modifier_id: a.id)
      expect(trade.can_be_modified_by?(a)).to be false
      expect(trade.can_be_modified_by?(b)).to be true
    end

    it "still allows both participants to modify a pending trade" do
      trade = create(:trade, :pending, user: a, user_invit: b)
      expect(trade.can_be_modified_by?(a)).to be true
      expect(trade.can_be_modified_by?(b)).to be true
    end
  end

  describe "Notification.create_trade_notification" do
    let(:user) { create(:user) }

    it "flags action-required notifications and links to the trade" do
      n = Notification.create_trade_notification(user.id, 7, "à valider", action_required: true)
      expect(n.action_required?).to be true
      expect(n.resource_path).to eq("/trades/7")
    end

    it "treats plain trade notifications as informational" do
      n = Notification.create_trade_notification(user.id, 7, "info")
      expect(n.action_required?).to be false
      expect(n.resource_path).to eq("/trades/7")
    end
  end
end
