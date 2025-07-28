import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["display", "form", "editButton"];
  static values = { itemId: Number };

  // Toggle strikethrough
  toggleStrikethrough(event) {
    const checkbox = event.target;
    const textSpan = checkbox.closest('.form-check').querySelector('.checklist-text');

    textSpan.classList.toggle('text-decoration-line-through', checkbox.checked);
    textSpan.classList.toggle('text-muted', checkbox.checked);

    this.updateCheckStatus(checkbox.checked);
  }

  // Show edit form
  showForm() {
    this.displayTarget.classList.add("d-none");
    this.formTarget.classList.remove("d-none");
    this.editButtonTarget.classList.add("d-none"); // Hide edit button when editing
  }

  // Cancel editing
  cancel() {
    this.formTarget.classList.add("d-none");
    this.displayTarget.classList.remove("d-none");
    this.editButtonTarget.classList.remove("d-none"); // Show edit button again
  }

  // Update after successful edit
  update(event) {
    const [_data, _status, xhr] = event.detail;
    this.displayTarget.innerHTML = xhr.responseText;
    this.cancel();
  }

  // Handle edit errors
  error(event) {
    const [data, status, xhr] = event.detail;
    this.formTarget.innerHTML = xhr.response;
  }

  // Private method to update check status
  updateCheckStatus(checked) {
    fetch(`/checklist_items/${this.itemIdValue}/toggle`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ checked })
    }).catch(error => console.error('Error:', error));
  }
}
