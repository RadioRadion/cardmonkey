class Extension < ApplicationRecord
    has_many :card_versions

    validates :code, presence: true
    validates :name, presence: true
    validates :release_date, presence: true
    validates :icon_uri, presence: true
end

