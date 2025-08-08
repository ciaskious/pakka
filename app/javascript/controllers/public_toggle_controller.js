import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }
  static targets = ["wrapper", "label"]

  connect() {
    console.log("PublicToggleController connected")
  }

  toggle(event) {
    event.preventDefault()

    fetch(this.urlValue, {
      method:  "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
        "Accept":       "application/json"
      },
      credentials: "same-origin"
    })
    .then(r => r.json())
    .then(data => {
      const isPublic = data.public

      // update track & knob
      this.wrapperTarget.classList.toggle("active", isPublic)
      // update text label
      this.labelTarget.textContent = isPublic
        ? "Public 🌐"
        : "Private 🔒"
    })
    .catch(err => console.error("Toggle failed:", err))
  }
}
