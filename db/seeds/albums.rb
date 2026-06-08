# A sample shared album mirroring the prototype's "Lisbon & the Algarve" content, so
# `bin/rails db:seed` and the test suite share one realistic, labelled dataset.

# Real images extracted from the design bundle (db/seeds/files/photos/), cycled across moments.
photos_pool = Rails.root.glob("db/seeds/files/photos/*.jpg").sort.cycle
file_for = lambda do
  path = photos_pool.next
  {io: File.open(path), filename: path.basename.to_s, content_type: "image/jpeg"}
end

# A real short clip for the video moments, so the duration (and poster) come from actual
# Active Storage analysis (needs ffmpeg, see CLAUDE.md).
video_path = Rails.root.join("db/seeds/files/videos/movie-short.mp4")
video_for = lambda do
  {io: File.open(video_path), filename: video_path.basename.to_s, content_type: "video/mp4"}
end

# Fixed slug so the album is trivial to open in development (/albums/test).
album = albums.create(:lisbon, title: "Lisbon & the Algarve", slug: "test")

# Ownerships: created creator-first; the positioning gem assigns `position` in creation order,
# and a user's index in that order maps to their palette color (first = ember).
priya = ownerships.create(:priya, album:, role: :creator, user: users.create(:priya, unique_by: :email, name: "Priya", email: "priya@example.com"))
marco = ownerships.create(:marco, album:, user: users.create(:marco, unique_by: :email, name: "Marco", email: "marco@example.com", roles: ["admin"]))
lena = ownerships.create(:lena, album:, user: users.create(:lena, unique_by: :email, name: "Lena", email: "lena@example.com"))
jonas = ownerships.create(:jonas, album:, user: users.create(:jonas, unique_by: :email, name: "Jonas", email: "jonas@example.com"))
ada = ownerships.create(:ada, album:, user: users.create(:ada, unique_by: :email, name: "Ada", email: "ada@example.com"))
theo = ownerships.create(:theo, album:, user: users.create(:theo, unique_by: :email, name: "Theo", email: "theo@example.com"))
people = {priya:, marco:, lena:, jonas:, ada:, theo:}

# A user with no album membership — handy for tests that need a fresh-to-the-album person.
users.create(:nomad, unique_by: :email, name: "Nomad", email: "nomad@example.com")

start = Time.utc(2026, 6, 14, 9, 0, 0)
items = [
  {key: :tram, kind: :photo, by: :priya, at: start},
  {key: :tiles, kind: :photo, by: :jonas, at: start + 33.minutes},
  {kind: :photo, by: :marco, at: start + 4.hours},
  {kind: :photo, by: :lena, at: start + 5.hours},
  {key: :rooftop, kind: :photo, by: :priya, at: start + 9.hours},
  {key: :skyline, kind: :video, by: :ada, at: start + 9.hours + 30.minutes},
  {key: :sintra, kind: :photo, by: :lena, at: start + 1.day},
  {kind: :photo, by: :marco, at: start + 1.day + 1.hour},
  {kind: :video, by: :jonas, at: start + 1.day + 2.hours},
  {key: :bluehour, kind: :photo, by: :lena, at: start + 1.day + 10.hours},
  {key: :cliffs, kind: :photo, by: :jonas, at: start + 2.days},
  {kind: :photo, by: :ada, at: start + 2.days + 1.hour},
  {key: :lastnight, kind: :photo, by: :priya, at: start + 2.days + 9.hours}
]

# Triple the first two days (day 0: 6 -> 18, day 1: 4 -> 12) by adding extra photo
# moments spread across each day, cycling uploaders, so the grid fills out.
uploader_cycle = people.keys.cycle
{0 => 12, 1 => 8}.each do |day, count|
  count.times do |i|
    items << {kind: :photo, by: uploader_cycle.next, at: start + day.days + (40 * (i + 1)).minutes}
  end
end

items.each do |item|
  video = item[:kind] == :video
  table = video ? videos : photos
  attrs = {album:, uploader: people.fetch(item[:by]), captured_at: item[:at], file: video ? video_for.call : file_for.call}
  record = item[:key] ? table.create(item[:key], **attrs) : table.create(**attrs)
  # Analyze videos up front so `duration` is available without waiting on the async job.
  record.file.blob.analyze if video
end

# Likes (one per ownership per moment).
[:marco, :lena, :jonas].each { |k| likes.create(moment: photos.tram, ownership: people[k]) }
[:priya, :ada].each { |k| likes.create(moment: photos.tiles, ownership: people[k]) }
[:marco, :lena, :jonas, :ada].each { |k| likes.create(moment: photos.rooftop, ownership: people[k]) }
[:priya, :marco, :jonas, :ada].each { |k| likes.create(moment: photos.bluehour, ownership: people[k]) }
[:marco, :lena, :jonas, :ada, :theo].each { |k| likes.create(moment: photos.lastnight, ownership: people[k]) }

# Comments.
comments.create(moment: photos.tram, author: lena, body: "this is SO lisbon")
comments.create(moment: photos.rooftop, author: ada, body: "frame this one")
comments.create(moment: photos.rooftop, author: marco, body: "the light here was unreal")
comments.create(moment: photos.rooftop, author: lena, body: "we stayed until the bells")
comments.create(moment: photos.rooftop, author: jonas, body: "best rooftop of the trip")
comments.create(moment: photos.bluehour, author: priya, body: "my favourite of the trip")
comments.create(moment: photos.lastnight, author: marco, body: "same time next year")
comments.create(moment: photos.lastnight, author: jonas, body: "booking it now")
