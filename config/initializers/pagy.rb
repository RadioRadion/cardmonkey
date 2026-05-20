# Pagy configuration
require 'pagy/extras/overflow'
require 'pagy/extras/array'

Pagy::DEFAULT[:items] = 15
Pagy::DEFAULT[:size] = [1, 2, 2, 1]
Pagy::DEFAULT[:overflow] = :last_page
