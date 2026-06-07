import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";

// Drives the upload sidebar: each chosen/dropped file starts an Active Storage
// direct upload (browser → storage). At most MAX_CONCURRENT run at once; the rest
// wait in a "queued" state and start as slots free up. Successful uploads add a
// hidden signed_id field to the form; failures expose a Retry. Submit is enabled
// once at least one upload is done and none are still queued or in flight.
export default class extends Controller {
  static targets = ["input", "list", "rowTemplate", "fields", "submit", "count"];
  static values = { directUploadUrl: String, labels: Object };

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
    row.querySelector(".upload-sidebar__name").textContent = file.name;
    if (file.type.startsWith("image/")) {
      row.querySelector(".upload-sidebar__thumb").style.backgroundImage = `url(${URL.createObjectURL(file)})`;
    }
    this.listTarget.appendChild(row);
    this.enqueue(row);
  }

  // Mark the row as waiting and try to fill an upload slot.
  enqueue(row) {
    this.removeField(row);
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
        this.addField(row, blob.signed_id);
      }
      this.pump();
      this.refresh();
    });
    this.refresh();
  }

  retry(event) {
    this.enqueue(this.rowFor(event));
  }

  removeFile(event) {
    const row = this.rowFor(event);
    this.queue = this.queue.filter((queued) => queued !== row);
    this.removeField(row);
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
    const text = state === "uploading" ? "0%" : this.labelsValue[state] || "";
    row.querySelector(".upload-sidebar__status-text").textContent = text;
  }

  setProgress(row, percent) {
    row.querySelector(".upload-sidebar__bar").style.width = `${percent}%`;
    if (row.dataset.state === "uploading") {
      row.querySelector(".upload-sidebar__status-text").textContent = `${percent}%`;
    }
  }

  addField(row, signedId) {
    this.removeField(row);
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = "signed_ids[]";
    input.value = signedId;
    input.dataset.rowId = this.rowId(row);
    this.fieldsTarget.appendChild(input);
  }

  removeField(row) {
    const field = this.fieldsTarget.querySelector(`input[data-row-id="${this.rowId(row)}"]`);
    if (field) field.remove();
  }

  rowFor(event) {
    return event.currentTarget.closest(".upload-sidebar__row");
  }

  rowId(row) {
    if (!row.dataset.rowId) {
      row.dataset.rowId = `${this.idCounter++}`;
    }
    return row.dataset.rowId;
  }

  refresh() {
    const rows = Array.from(this.listTarget.children);
    const done = rows.filter((row) => row.dataset.state === "done").length;
    const pending = rows.some((row) => row.dataset.state === "uploading" || row.dataset.state === "queued");

    this.countTarget.textContent = rows.length ? String(rows.length) : "";
    this.submitTarget.disabled = done === 0 || pending;
    this.submitTarget.textContent = pending
      ? this.labelsValue.submitUploading
      : done > 0
        ? this.labelsValue.submitCount.replace("%{count}", done)
        : this.labelsValue.submit;
  }
}
