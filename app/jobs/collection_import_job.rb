# Runs a (potentially large) collection import off the request cycle and
# notifies the user when done. Re-parses the raw content server-side so we never
# trust client-built rows.
class CollectionImportJob < ApplicationJob
  queue_as :default

  def perform(user_id, source_type, content, defaults = {})
    user = User.find_by(id: user_id)
    return unless user

    rows = CollectionImport.parse(source_type, content, defaults.symbolize_keys)
    result = CollectionImport::Importer.new(user).call(rows)

    Notification.create_notification(
      user.id,
      I18n.t("notifications.import.done",
             added: result.total_added,
             skipped: result.skipped_count,
             default: "Import terminé : #{result.total_added} carte(s) ajoutée(s), #{result.skipped_count} ignorée(s).")
    )
  end
end
