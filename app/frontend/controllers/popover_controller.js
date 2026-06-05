import { Controller } from "@hotwired/stimulus";

// Opens a Shimmer popover anchored to this element, loading its body from `urlValue`.
export default class extends Controller {
  static values = {
    url: String,
    placement: { type: String, default: "bottom-start" },
  };

  open(event) {
    // Stop the click from reaching document, or shimmer's own click-outside
    // handler would catch this same event and close the popover immediately.
    event.preventDefault();
    event.stopPropagation();
    window.ui.popover.open({
      url: this.urlValue,
      selector: this.element,
      placement: this.placementValue,
    });
  }
}
