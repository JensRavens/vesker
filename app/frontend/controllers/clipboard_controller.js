import { Controller } from "@hotwired/stimulus";

// Copies `textValue` to the clipboard and flips the button to a "Copied" state
// (data-copied) for a moment — the label/icon swap is handled in CSS.
export default class extends Controller {
  static values = { text: String };

  copy() {
    navigator.clipboard?.writeText(this.textValue);
    this.element.dataset.copied = "true";
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => delete this.element.dataset.copied, 1800);
  }
}
