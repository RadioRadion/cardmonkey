module ApplicationHelper

  def card_image_tag(card_version, options = {})
    if card_version&.img_uri.present?
      image_tag(card_version.img_uri, options)
    else
      # Utilise une div avec un fond gris et un icône plutôt qu'une image placeholder
      content_tag(:div, class: "#{options[:class]} bg-gray-100 flex items-center justify-center") do
        content_tag(:svg, class: "text-gray-400 h-6 w-6", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
          content_tag(:path, "", stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z")
        end
      end
    end
  end

  def number_to_human_distance(distance)
    return "À proximité" if distance < 1
    return "#{distance.round} km" if distance < 20
    "#{(distance/10.0).round*10} km"
  end
end
