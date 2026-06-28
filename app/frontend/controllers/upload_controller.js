import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";

// Drives the upload sidebar: each chosen/dropped file starts an Active Storage direct upload
// (browser → storage). At most MAX_CONCURRENT run at once; the rest wait in a "queued" state and
// start as slots free up. When a file finishes uploading its row's turbo-frame form auto-submits
// the signed blob id, and the server creates the moment (or reports a duplicate) and renders the
// status back into that frame. Failures expose a Retry.
export default class extends Controller {
  static targets = ["input", "list", "rowTemplate", "count"];
  static values = { directUploadUrl: String };

  static MAX_CONCURRENT = 5;

  connect() {
    this.files = new WeakMap();
    this.queue = [];
    this.active = 0;
    this.idCounter = 0;
    this.refresh();
  }

  filesChosen() {
    Array.from(this.inputTarget.files).forEach((file) => this.addFile(file));
    this.inputTarget.value = ""; // allow re-picking the same file
  }

  addFile(file) {
    const row = this.rowTemplateTarget.content.firstElementChild.cloneNode(true);
    this.files.set(row, file);
    row.querySelector("turbo-frame").id = `upload_row_${this.idCounter++}`;
    row.querySelector(".upload-sidebar__name").textContent = file.name;
    if (file.type.startsWith("image/")) {
      row.querySelector(".upload-sidebar__thumb").style.backgroundImage = `url(${URL.createObjectURL(file)})`;
    }
    this.listTarget.appendChild(row);
    this.enqueue(row);
  }

  // Mark the row as waiting and try to fill an upload slot.
  enqueue(row) {
    this.setState(row, "queued");
    this.queue.push(row);
    this.pump();
    this.refresh();
  }

  pump() {
    while (this.active < this.constructor.MAX_CONCURRENT && this.queue.length) {
      this.startUpload(this.queue.shift());
    }
  }

  startUpload(row) {
    this.active++;
    this.setState(row, "uploading");
    this.setProgress(row, 0);

    const upload = new DirectUpload(this.files.get(row), this.directUploadUrlValue, this.progressDelegate(row));
    upload.create((error, blob) => {
      this.active--;
      if (error) {
        this.setState(row, "failed");
      } else {
        this.setState(row, "done");
        this.submitRow(row, blob.signed_id);
      }
      this.pump();
      this.refresh();
    });
    this.refresh();
  }

  // Hand the signed blob to the row's turbo-frame form; the server swaps in the moment's status.
  submitRow(row, signedId) {
    const form = row.querySelector("form");
    form.querySelector("input[name='signed_id']").value = signedId;
    form.requestSubmit();
  }

  retry(event) {
    this.enqueue(this.rowFor(event));
  }

  removeFile(event) {
    const row = this.rowFor(event);
    this.queue = this.queue.filter((queued) => queued !== row);
    row.remove();
    this.refresh();
  }

  progressDelegate(row) {
    return {
      directUploadWillStoreFileWithXHR: (xhr) => {
        xhr.upload.addEventListener("progress", (event) => {
          if (event.lengthComputable) {
            this.setProgress(row, Math.round((event.loaded / event.total) * 100));
          }
        });
      },
    };
  }

  setState(row, state) {
    row.dataset.state = state;
  }

  setProgress(row, percent) {
    row.querySelector(".upload-sidebar__bar").style.width = `${percent}%`;
  }

  rowFor(event) {
    return event.currentTarget.closest(".upload-sidebar__row");
  }

  refresh() {
    const count = this.listTarget.children.length;
    this.countTarget.textContent = count ? String(count) : "";
  }
}
