---
applyTo: "site/**/*"
---

The `site` directory contains the source code for a static website managed by an internal library called **Hotpages**. Below is an explanation of the roles of each subdirectory within `site`.

- **pages**
  - Contains files that define the website's pages
  - File paths correspond directly to the paths used for serving the pages

- **layouts**
  - Stores layout template files
  - `site.html.erb` is the default layout template
  - Pages are wrapped with the specified layout during rendering
  - Equivalent to layouts in Ruby on Rails

- **partials**
  - Contains partial templates
  - Partials can be used within pages, layouts, or other partials
  - Equivalent to partials in Ruby on Rails

- **models**
  - Stores Ruby model files
  - Equivalent to models in Ruby on Rails

- **assets**
  - Stores assets such as CSS, JavaScript (jsm), and images
  - CSS files are placed under the `css` subdirectory and loaded via `site.css`
  - JavaScript files using the Stimulus framework are stored in the `controllers` subdirectory and loaded via `site.js`

- **helpers**
  - Contains helper functions available in templates and Ruby Page objects
  - Helpers should be split into separate files by role
  - Equivalent to helpers in Ruby on Rails

Please organize your files according to the roles of these directories.
