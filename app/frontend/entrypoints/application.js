import "@hotwired/turbo-rails";
import { Application } from "@hotwired/stimulus";
import { start } from "@nerdgeschoss/shimmer";
import PopoverController from "../controllers/popover_controller";

const application = Application.start();
application.register("popover", PopoverController);
start({ application });

import "../styles/reset.css";
import "../styles/tokens.scss";
import "../styles/popover.scss";

// Colocated component stylesheets (each Phlex component ships its own SCSS; views carry none).
import.meta.glob("../../components/**/*.scss", { eager: true });
