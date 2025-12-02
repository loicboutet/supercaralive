require 'redcarpet'

module ApplicationHelper
  include Pagy::Frontend

  # Pagy helper that matches the mockup design
  # Used for all pagination throughout the application
  def pagy_nav_supercaralive(pagy, **vars)
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
    pagy_nav_supercaralive(pagy, **vars)
  end

  # Helper method to render Lucide icons
  # Usage: <%= lucide_icon('x', size: 'w-4 h-4', class: 'opacity-60') %>
  def lucide_icon(name, size: nil, **options)
    css_class = options.delete(:class)
    classes = [size, css_class].compact.join(' ')
    tag.i('', data: { lucide: name }, class: classes.presence, **options)
  end

  # Helper method to display user profile photo or initials
  # Returns the content (image + hidden initials, or just initials + hidden img for stimulus) to be placed inside a container
  # Usage: 
  #   <div class="w-32 h-32 bg-blue-hero rounded-lg relative">
  #     <%= user_avatar_content(user, image_class: "w-full h-full object-cover", initials_class: "text-white text-5xl font-bold") %>
  #   </div>
  # Options:
  #   - image_class: CSS classes for the image tag (default: "w-full h-full object-cover")
  #   - initials_class: CSS classes for the initials span (default: "text-white font-bold absolute inset-0 flex items-center justify-center")
  #   - image_data: Data attributes for the image (useful for stimulus controllers)
  #   - initials_data: Data attributes for the initials span (useful for stimulus controllers)
  #   - include_stimulus_img: If true, includes a hidden img tag for stimulus controller when no photo (default: false)
  def user_avatar_content(user, image_class: "w-full h-full object-cover", initials_class: "text-white font-bold absolute inset-0 flex items-center justify-center", image_data: {}, initials_data: {}, include_stimulus_img: false)
    return "" unless user

    # Check if photo is attached AND blob exists (to avoid browser trying to load non-existent files)
    begin
      photo_available = user.profile_photo.attached? && user.profile_photo.blob.present?
    rescue
      photo_available = false
    end
    
    if photo_available
      # Add error handler to show initials if image fails to load
      image_tag(user.profile_photo, class: image_class, data: image_data, onerror: "this.style.display='none'; this.nextElementSibling.classList.remove('hidden');") +
      content_tag(:span, user.get_initials, class: "#{initials_class} hidden", data: initials_data)
    else
      result = content_tag(:span, user.get_initials, class: initials_class, data: initials_data)
      if include_stimulus_img && image_data.present?
        # Create a hidden img tag for stimulus controller without src to avoid browser request
        result += tag.img(class: "#{image_class} hidden", data: image_data)
      end
      result
    end
  end

  # Helper method to get the support email from AppConfig
  # Usage: <%= support_email %> or <%= mail_to support_email %>
  def support_email
    app_config = AppConfig.instance
    app_config.contact_email.presence || Rails.application.credentials.support_email rescue nil
  end
  
  # Helper method to get the contact phone from AppConfig
  # Usage: <%= contact_phone %>
  def contact_phone
    AppConfig.instance.contact_phone
  end

  # Helper to check if booking date is past (considering service duration)
  # Usage: <%= booking_date_passed?(@booking) %>
  def booking_date_passed?(booking)
    return false unless booking.scheduled_at.present?
    duration_minutes = booking.professional_service&.duration_minutes || 60
    end_time = booking.scheduled_at + duration_minutes.minutes
    end_time < Time.current
  end

  # Helper to format waiting time in a human-readable way
  # Converts hours to days when >= 24 hours
  # Usage: <%= format_waiting_time(user.created_at) %>
  # Returns: "5h", "1 jour", "2 jours", "3j 12h", etc.
  def format_waiting_time(created_at)
    return "0h" unless created_at.present?
    
    hours = ((Time.current - created_at) / 1.hour).round
    days = (hours / 24.0).floor
    
    if days >= 1
      remaining_hours = hours % 24
      if remaining_hours > 0
        "#{days}j #{remaining_hours}h"
      else
        "#{days} jour#{days > 1 ? 's' : ''}"
      end
    else
      "#{hours}h"
    end
  end

  # Helper to convert markdown to HTML
  # Usage: <%= markdown_to_html(markdown_text) %>
  def markdown_to_html(markdown_text)
    return "" unless markdown_text.present?
    
    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,
      no_images: false,
      no_links: false,
      no_styles: false,
      safe_links_only: true,
      hard_wrap: true,
      link_attributes: { target: "_blank", rel: "noopener noreferrer" }
    )
    
    markdown = Redcarpet::Markdown.new(renderer, {
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true,
      underline: true,
      highlight: true,
      quote: true,
      footnotes: true
    })
    
    markdown.render(markdown_text).html_safe
  end
end
