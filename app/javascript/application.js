import Rails from "@rails/ujs"
Rails.start()

import { Application } from "@hotwired/stimulus"
import InlineEditController from "controllers/inline_edit_controller"
import PublicToggleController from "controllers/public_toggle_controller"

const application = Application.start()
application.register("inline-edit", InlineEditController)
application.register("public-toggle", PublicToggleController)

import "@popperjs/core"
import "bootstrap"
