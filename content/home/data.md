+++
# Hero widget.
widget = "hero"  # See https://sourcethemes.com/academic/docs/page-builder/
headless = true  # This file represents a page section.
active = true  # Activate this widget? true/false
weight = 100  # Order that this section will appear.

# title = "The Urban Politics and Governance research group at McGill University"

# Hero image (optional). Enter filename of an image in the `static/img/` folder.
hero_media = "code.png"

[design.background]
  # Apply a background color, gradient, or image.
  #   Uncomment (by removing `#`) an option to apply it.
  #   Choose a light or dark text color by setting `text_color_light`.
  #   Any HTML color name or Hex value is valid.

  # Background color.
  color = "#5B70BA"
  
  # Background gradient.
  # gradient_start = "#4bb4e3"
  # gradient_end = "#2b94c3"
  
  # Background image.
  # image = ""  # Name of image in `static/img/`.
  # image_darken = 0.6  # Darken the image? Range 0-1 where 0 is transparent and 1 is opaque.

  # Text color (true=light or false=dark).
  text_color_light = true

# Call to action links (optional).
#   Display link(s) by specifying a URL and label below. Icon is optional for `[cta]`.
#   Remove a link/note by deleting a cta/note block.
[cta]
  url = "https://github.com/UPGo-McGill"
  label = "UPGo on Github"
  icon_pack = "fab"
  icon = "github"
  
# Note. An optional note to show underneath the links.
#[cta_note]
#  label = '<a id="academic-release" href="https://sourcethemes.com/academic/updates" #data-repo="gcushen/hugo-academic">Latest release <!-- V --></a>'
+++

# **Open data science at UPGo**

All of the code for our quantitative analysis projects is freely available for replication and repurposing on our [team Github page](https://github.com/UPGo-McGill). We often work with proprietary data which we are unable to share, but where we are using public data we share that as well.

We are also working to develop **strr**, an R package for cleaning, analyzing and visualizing short-term rental data. We expect to release a stable version to CRAN later in 2019, but [the development version](https://github.com/UPGo-McGill/strr) is now available for testing and feedback.

