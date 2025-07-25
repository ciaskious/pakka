import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["display", "form"];
  static values = { itemId: Number };

  connect() {
    console.log("InlineEdit controller connected");
  }

  showForm() {
    this.displayTarget.classList.add("d-none");
    this.formTarget.classList.remove("d-none");
  }

  cancel() {
    this.formTarget.classList.add("d-none");
    this.displayTarget.classList.remove("d-none");
  }

  update(event) {
    const [html] = event.detail;
    this.displayTarget.innerHTML = html;
    this.cancel();
  }

  error(event) {
    const [data, status, xhr] = event.detail;
    this.formTarget.innerHTML = xhr.response;
  }
}
