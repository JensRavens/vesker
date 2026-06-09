import { Turbo } from "@hotwired/turbo-rails";
import { Application } from "@hotwired/stimulus";
import { start } from "@nerdgeschoss/shimmer";
import PopoverController from "../controllers/popover_controller";
import ModalController from "../controllers/modal_controller";
import UploadController from "../controllers/upload_controller";
import ClipboardController from "../controllers/clipboard_controller";
import PasskeyController from "../controllers/passkey_controller";

const application = Application.start();
application.register("popover", PopoverController);
application.register("modal", ModalController);
application.register("upload", UploadController);
application.register("clipboard", ClipboardController);
application.register("passkey", PasskeyController);
start({ application });

// Back Turbo's confirm (data-turbo-confirm) with the design's styled <dialog>
// (Components::ConfirmDialog in the layout) instead of the native browser confirm.
// Swap in the action's message; resolve true only when the Delete button submits.
Turbo.setConfirmMethod((message) => {
  const dialog = document.getElementById("confirm-dialog");
  const messageEl = dialog.querySelector(".modal-card__subhead p");
  if (messageEl && message) messageEl.textContent = message;
  dialog.showModal();
  return new Promise((resolve) => {
    dialog.addEventListener("close", () => resolve(dialog.returnValue === "confirm"), { once: true });
  });
});

// Close any open popover/modal before navigating, so a lingering click-outside
// listener doesn't swallow the first click on the next page.
document.addEventListener("turbo:before-visit", () => {
  window.ui?.popover?.close();
  window.ui?.modal?.close();
});

// Expose Turbo's render method ("replace" for a navigation, "morph" for a same-page
// refresh) on <html> so view-transition CSS can distinguish them — e.g. the moment
// sidebar slides in on navigation but only cross-fades on a morph (like toggle).
document.addEventListener("turbo:before-render", (event) => {
  document.documentElement.dataset.turboRenderMethod = event.detail.renderMethod;
});

import "../styles/reset.css";
import "../styles/tokens.scss";
import "../styles/popover.scss";
import "../styles/modal.scss";

// Colocated component stylesheets (each Phlex component ships its own SCSS; views carry none).
import.meta.glob("../../components/**/*.scss", { eager: true });
