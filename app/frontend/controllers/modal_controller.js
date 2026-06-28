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
    // Shimmer injects the modal as a plain `body > .modal`; a Turbo morph refresh (e.g. a live
    // broadcast on the page underneath, fired when an upload lands) would otherwise delete it and
    // close the modal mid-task. Marking it permanent makes the morph leave it — and its in-flight
    // upload state — untouched. (Shimmer still removes it itself on close / before a navigation.)
    document.querySelectorAll("body > .modal, body > .modal-blind").forEach((el) => {
      el.setAttribute("data-turbo-permanent", "");
    });
  }

  close(event) {
    event?.preventDefault();
    window.ui.modal.close();
  }
}
