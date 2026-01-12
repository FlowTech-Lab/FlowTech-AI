---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.830612'
id: 9fbe0b12-c8e8-4fb6-bdf2-a41585fdf813
title: doc-9fbe0b12-c8e8-4fb6-bdf2-a41585fdf813
---

# Boucle simple avec index
100.times do |i|
  User.create!(first_name: "Nom#{i}", email: "email#{i}@example.com")
end

# Faker / Faussaire pour données réalistes
require "faker"
# require "faussaire" # alternative FR
20.times do
  User.create!(
    first_name: Faker::Name.first_name,
    email:      Faker::Internet.email
  )
end

# Idempotence par clé naturelle (upsert-like)
def seed_user(attrs)
  u = User.find_or_initialize_by(email: attrs[:email])
  u.assign_attributes(attrs)
  u.save!
end

seed_user(first_name: "Admin", email: "admin@example.com")

# Transactions pour gros volumes
ActiveRecord::Base.transaction do
  items.each { |attrs| Model.create!(attrs) }
end
```