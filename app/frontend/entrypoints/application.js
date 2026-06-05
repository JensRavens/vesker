import "@hotwired/turbo-rails";

import "../styles/reset.css";
import "../styles/tokens.scss";

// Colocated component stylesheets (each Phlex component ships its own SCSS; views carry none).
import.meta.glob("../../components/**/*.scss", { eager: true });
