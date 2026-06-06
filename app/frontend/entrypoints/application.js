import "@hotwired/turbo-rails";
import { Application } from "@hotwired/stimulus";
import { start } from "@nerdgeschoss/shimmer";
import PopoverController from "../controllers/popover_controller";

const application = Application.start();
application.register("popover", PopoverController);
start({ application });

// Close any open popover before navigating, so its document click-outside listener
// doesn't linger across the Turbo visit and swallow the next click.
document.addEventListener("turbo:before-visit", () => window.ui?.popover?.close());

import "../styles/reset.css";
import "../styles/tokens.scss";
import "../styles/popover.scss";

// Colocated component stylesheets (each Phlex component ships its own SCSS; views carry none).
import.meta.glob("../../components/**/*.scss", { eager: true });
