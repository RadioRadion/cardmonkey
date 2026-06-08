# Pagy configuration
require 'pagy/extras/overflow'
require 'pagy/extras/array'

Pagy::DEFAULT[:limit] = 15
Pagy::DEFAULT[:size] = 7
Pagy::DEFAULT[:overflow] = :last_page
