# Be sure to restart your server when you modify this file.
#
# Content Security Policy. Enabled in REPORT-ONLY mode first: the browser reports
# violations without blocking, so the policy can be validated against real
# traffic before enforcing. Flip `content_security_policy_report_only` to false
# once reports are clean.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    # Card art (Scryfall CDN), set icons, user avatars (Cloudinary), data URIs.
    policy.img_src     :self, :https, :data, "https://cards.scryfall.io",
                       "https://svgs.scryfall.io", "https://res.cloudinary.com"
    policy.object_src  :none
    # Hotwire/Stimulus + importmap shims rely on inline; tighten with nonces later.
    policy.script_src  :self, :https, :unsafe_inline
    policy.style_src   :self, :https, :unsafe_inline
    policy.connect_src :self, :https, :wss
  end

  config.content_security_policy_report_only = true
end
