import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  static values = { showUrl: String }

  connect() {
    this.element.textContent = "Hello World!";
  }

  toggleEdit() {
    this.displayTarget.classList.add("d-none");
    this.formTarget.classList.remove("d-none");
  }

  cancelEdit() {
   fetch(this.showUrlValue)
      .then(res => res.text())
      .then(html => {
        this.element.outerHTML = html
      })
  }

  success(event) {
    const [data, _status, xhr] = event.detail;
    this.element.outerHTML = xhr.response;
  }

  error(event) {
    alert("Update failed.");
  }
}
