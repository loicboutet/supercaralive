module ApplicationHelper
  include Pagy::Frontend

  # Pagy helper that matches the mockup design
  # Used for all pagination throughout the application
  def pagy_nav_hatmada(pagy, **vars)
    html = +%(<div class="flex items-center justify-center mt-8 space-x-2">)

    # Previous button
    if pagy.prev
      html << %(<a href="#{pagy_url_for(pagy, pagy.prev, **vars)}" class="px-4 py-2 border border-gray-300 rounded-lg text-gray-600 hover:bg-gray-50 inline-flex items-center">)
      html << %(<span class="flex items-center">)
      html << %(<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">)
      html << %(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>)
      html << %(</svg>)
      html << %(Précédent)
      html << %(</span>)
      html << %(</a>)
    else
      html << %(<button class="px-4 py-2 border border-gray-300 rounded-lg text-gray-600 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed inline-flex items-center" disabled>)
      html << %(<span class="flex items-center">)
      html << %(<svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">)
      html << %(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>)
      html << %(</svg>)
      html << %(Précédent)
      html << %(</span>)
      html << %(</button>)
    end

    # Page numbers
    pagy.series(**vars).each do |item|
      case item
      when Integer
        if item == pagy.page
          html << %(<button class="px-4 py-2 bg-red-hero text-white rounded-lg font-medium">#{item}</button>)
        else
          html << %(<a href="#{pagy_url_for(pagy, item, **vars)}" class="px-4 py-2 border border-gray-300 rounded-lg text-gray-600 hover:bg-gray-50">#{item}</a>)
        end
      when String
        case item
        when "gap"
          html << %(<span class="px-2 text-gray-500">...</span>)
        end
      end
    end

    # Next button
    if pagy.next
      html << %(<a href="#{pagy_url_for(pagy, pagy.next, **vars)}" class="px-4 py-2 border border-gray-300 rounded-lg text-gray-600 hover:bg-gray-50 inline-flex items-center">)
      html << %(<span class="flex items-center">)
      html << %(Suivant)
      html << %(<svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">)
      html << %(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>)
      html << %(</svg>)
      html << %(</span>)
      html << %(</a>)
    else
      html << %(<button class="px-4 py-2 border border-gray-300 rounded-lg text-gray-600 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed inline-flex items-center" disabled>)
      html << %(<span class="flex items-center">)
      html << %(Suivant)
      html << %(<svg class="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">)
      html << %(<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>)
      html << %(</svg>)
      html << %(</span>)
      html << %(</button>)
    end

    html << %(</div>)
    html.html_safe
  end

  # Legacy method for backward compatibility - redirects to new helper
  def pagy_nav_tailwind(pagy, **vars)
    pagy_nav_hatmada(pagy, **vars)
  end
end
