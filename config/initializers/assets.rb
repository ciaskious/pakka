# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
# Rails.application.config.assets.precompile += %w(bootstrap.min.js popper.js)

# Tell Sprockets about your JS controllers folder
Rails.application.config.assets.paths << Rails.root.join("app/javascript")

# Precompile all files under controllers so they end up in public/assets
Rails.application.config.assets.precompile += %w[
  bootstrap.min.js
  popper.js
  controllers/index.js
  controllers/inline_edit_controller.js
  controllers/*.js
]
