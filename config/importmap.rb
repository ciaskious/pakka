# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@6.1.7/lib/assets/compiled/rails-ujs.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
pin "controllers", to: "controllers/index.js"
