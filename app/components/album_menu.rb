module Components
  class AlbumMenu < Base
    prop :album, Album

    def view_template
      div(class: "album-menu") do
        rename_row if policy(@album).update?
        share_row
        download_row(t(".download_all"), t(".download_all_sub"), "photo-library", download_album_path(@album))
        if current_user
          download_row(t(".download_others"), t(".download_others_sub"), "filter-none",
            download_album_path(@album, scope: :others))
        end
      end
    end

    private

    # Opens the rename modal (creator only; modal_controller closes this popover on open).
    def rename_row
      button(type: "button", class: "album-menu__row",
        data: {controller: "modal", action: "modal#open", modal_url_value: edit_album_path(@album)}) do
        row_body(t(".rename"), t(".rename_sub"), "edit")
      end
    end

    # Opens the share/QR modal (modal_controller closes this popover on open).
    def share_row
      button(type: "button", class: "album-menu__row",
        data: {controller: "modal", action: "modal#open", modal_url_value: share_album_path(@album)}) do
        row_body(t(".share"), t(".share_sub"), "share")
      end
    end

    # A real file download (not a Turbo visit), so the streamed zip downloads in place.
    def download_row(title, sub, icon_name, href)
      a(href:, class: "album-menu__row", data: {turbo: false}) do
        row_body(title, sub, icon_name)
      end
    end

    def row_body(title, sub, icon_name)
      icon(name: icon_name, size: 22)
      span(class: "album-menu__text") do
        text(type: "body", element: :span) { title }
        text(type: "caption", element: :span, color: "muted") { sub }
      end
    end
  end
end
