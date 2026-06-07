import { Controller } from "@hotwired/stimulus";

// Opens (or closes) a Shimmer modal, loading its body from `urlValue`.
export default class extends Controller {
  static values = {
    url: String,
    size: { type: String, default: "" },
  };

  open(event) {
    // Stop the click from reaching document, or shimmer's own click-outside
    // handler would catch this same event and close the modal immediately.
    event.preventDefault();
    event.stopPropagation();
    // Dismiss any open popover (e.g. the album menu the trigger lives in).
    window.ui.popover?.close();
    window.ui.modal.open({ url: this.urlValue, size: this.sizeValue });
  }

  close(event) {
    event?.preventDefault();
    window.ui.modal.close();
  }
}
