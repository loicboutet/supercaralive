# frozen_string_literal: true

# Pagy configuration
# See https://github.com/ddnexus/pagy/blob/master/lib/config/pagy.rb for available options

Pagy::DEFAULT[:items] = 10 # items per page
Pagy::DEFAULT[:size]  = [1, 4, 4, 1] # page size: [*, 4, 4, *]
Pagy::DEFAULT[:page_param] = :page
Pagy::DEFAULT[:params] = { page: 1 } # default params
Pagy::DEFAULT[:cycle] = true # when on last page, click "next" will go to first page

# Extras
# See https://ddnexus.github.io/pagy/extras

# Rails
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page

