// app/javascript/controllers/trip_dates_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startDate", "endDate", "submit"]

  validate() {
    const startDate = new Date(this.startDateTarget.value)
    const endDate = new Date(this.endDateTarget.value)

    if (startDate && endDate) {
      if (endDate < startDate) {
        this.endDateTarget.setCustomValidity("End date must be after start date")
        this.endDateTarget.classList.add("is-invalid")
      } else {
        this.endDateTarget.setCustomValidity("")
        this.endDateTarget.classList.remove("is-invalid")
      }
    }
    this.submitTarget.disabled = !this.formValid()
  }

  formValid() {
    return this.startDateTarget.reportValidity() && this.endDateTarget.reportValidity()
  }
}
