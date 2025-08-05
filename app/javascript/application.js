import Rails from "@rails/ujs"
Rails.start()

import { Application } from "@hotwired/stimulus"
import InlineEditController from "controllers/inline_edit_controller"

const application = Application.start()
application.register("inline-edit", InlineEditController)

import "@popperjs/core"
import "bootstrap"
