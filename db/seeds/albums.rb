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

# The people. Marco is the site admin; everyone else is a plain user. A person's palette color
# is their index among the album's uploaders, ordered by first upload (see Album#users).
priya = users.create(:priya, unique_by: :email, name: "Priya", email: "priya@example.com")
marco = users.create(:marco, unique_by: :email, name: "Marco", email: "marco@example.com", admin: true)
lena = users.create(:lena, unique_by: :email, name: "Lena", email: "lena@example.com")
jonas = users.create(:jonas, unique_by: :email, name: "Jonas", email: "jonas@example.com")
ada = users.create(:ada, unique_by: :email, name: "Ada", email: "ada@example.com")
theo = users.create(:theo, unique_by: :email, name: "Theo", email: "theo@example.com")
people = {priya:, marco:, lena:, jonas:, ada:, theo:}

# A user who never uploads to the album — handy for tests that need a fresh-to-the-album person.
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

# Run Active Storage's AnalyzeJob inline (and in-process) as each moment is created, so the
# `after_file_analyzed` hook analyzes, warms the grid representation, and reveals it before the seed
# finishes. Inline keeps it off a running dev worker, which would otherwise race the warming and
# corrupt SQLite. The curated `captured_at:` below wins over the file's own date, so the whole set
# stays on the intended June-2026 timeline (videos included). Needs libvips/ffmpeg.
previous_adapter = ActiveJob::Base.queue_adapter
ActiveJob::Base.queue_adapter = :inline
begin
  items.each do |item|
    video = item[:kind] == :video
    table = video ? videos : photos
    attrs = {album:, uploader: people.fetch(item[:by]), captured_at: item[:at], file: video ? video_for.call : file_for.call}
    item[:key] ? table.create(item[:key], **attrs) : table.create(**attrs)
  end
ensure
  ActiveJob::Base.queue_adapter = previous_adapter
end

# Likes (one per user per moment).
[:marco, :lena, :jonas].each { |k| likes.create(moment: photos.tram, user: people[k]) }
[:priya, :ada].each { |k| likes.create(moment: photos.tiles, user: people[k]) }
[:marco, :lena, :jonas, :ada].each { |k| likes.create(moment: photos.rooftop, user: people[k]) }
[:priya, :marco, :jonas, :ada].each { |k| likes.create(moment: photos.bluehour, user: people[k]) }
[:marco, :lena, :jonas, :ada, :theo].each { |k| likes.create(moment: photos.lastnight, user: people[k]) }

# Comments.
comments.create(moment: photos.tram, author: lena, body: "this is SO lisbon")
comments.create(moment: photos.rooftop, author: ada, body: "frame this one")
comments.create(moment: photos.rooftop, author: marco, body: "the light here was unreal")
comments.create(moment: photos.rooftop, author: lena, body: "we stayed until the bells")
comments.create(moment: photos.rooftop, author: jonas, body: "best rooftop of the trip")
comments.create(moment: photos.bluehour, author: priya, body: "my favourite of the trip")
comments.create(moment: photos.lastnight, author: marco, body: "same time next year")
comments.create(moment: photos.lastnight, author: jonas, body: "booking it now")
