(atx_heading
  [(atx_h1_marker) (atx_h2_marker) (atx_h3_marker) (atx_h4_marker) (atx_h5_marker) (atx_h6_marker)] @level
  heading_content: (_) @name
  (#set! "kind" "Interface")
  ) @symbol

(setext_heading
  heading_content: (_) @name
  (#set! "kind" "Interface")
  [(setext_h1_underline) (setext_h2_underline)] @level
  ) @symbol
