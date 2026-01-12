---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.818221'
id: 37b8f9bd-b73e-4fe3-b3e7-d0441e7da4e3
title: doc-37b8f9bd-b73e-4fe3-b3e7-d0441e7da4e3
---

```rb
# lib/app/spreadsheet_client.rb — Google Spreadsheet
require "google_drive"
class SpreadsheetClient
  def initialize(config_path: "config/google_credentials.json", spreadsheet_key: ENV["SPREADSHEET_KEY"])
    @session = GoogleDrive::Session.from_service_account_key(config_path)
    @ws = @session.spreadsheet_by_key(spreadsheet_key).worksheets.first
  end
  def save_hash(data)
    @ws[1,1] = "city"; @ws[1,2] = "email"
    row = 2
    data.each do |k, v|
      @ws[row,1] = k; @ws[row,2] = v; row += 1
    end
    @ws.save
  end
end
```

```rb
# lib/views/index.rb — menu minimal
class Index
  def ask_target
    puts "[1] JSON  [2] CSV  [3] Spreadsheet"
    (STDIN.gets || "").strip
  end
end
```

### 🔗 Relations / Composition
- `Scrapper` produit `data` (Hash) → consommé par `Saver` et `SpreadsheetClient`.
- `app.rb` orchestre: récupère `data`, choisit la cible, appelle `save_as_*`.
- `Views` gèrent l'I/O utilisateur. `Services` gèrent la logique.