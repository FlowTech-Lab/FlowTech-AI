---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.845354'
id: ec7ee2ab-ec5d-46b0-917e-abfd9c007245
title: doc-ec7ee2ab-ec5d-46b0-917e-abfd9c007245
---

```rb
# Console: création rapide et mise à jour ciblée
m1 = Movie.create!(name:"INPUT", year:2007, genre:"drame", synopsis:"INPUT", director:"INPUT", allocine_rating:3.4, my_rating:nil, already_seen:false)
Movie.where(already_seen:true)              # filtrer
Movie.find_by(name:"Beowulf")&.update!(allocine_rating:4.7)
Movie.find_by(name:"L'Exorciste")&.update!(genre:"comédie")
```

```rb
# Album/Track: seed minimal et affichage table_print
require "table_print"
Album.delete_all; Track.delete_all
a = Album.create!(title:"INPUT Album", artist:"INPUT Artist")
Track.create!([
  { title:"Song A", album:a.title, artist:a.artist, duration:180000, size:4000000, price:0.99 },
  { title:"Song B", album:a.title, artist:a.artist, duration:210000, size:5000000, price:0.99 }
])
tp Album.limit(5), :id, :title, :artist
tp Track.limit(5), :id, :title, :album, :duration, :price
```