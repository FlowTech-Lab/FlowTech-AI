---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.839224'
id: bdd38801-4f5a-448e-bb4e-7a04bf0af5c5
title: doc-bdd38801-4f5a-448e-bb4e-7a04bf0af5c5
---

### 🔗 Relations / Composition
- Un `Session` *contient* des infos temporelles et *dépend* de `Course` pour la durée.
- Les `callbacks` orchestrent des actions liées à la persistance (audit, mail, cache).
- Les méthodes d'instance exposent des calculs réutilisables et lisibles.
- Les validations protègent la BDD contre les entrées incohérentes.

### 🧪 Test / Validation
```bash
# En console Rails
u = User.create; u.errors.full_messages
u = User.create(email: "EMAIL"); u.persisted?
```
```rb
# RSpec minimal
it "requiert email" do
  expect(User.new.valid?).to eq(false)
end
```

### ⚙️ Build / Run / Deploy
- Migrer puis vérifier en console.
```bash
rails db:migrate
rails console
```
- Activer `deliver_later` avec Active Job/adapter si mails via callbacks.
- Surveiller logs: `log/development.log` pour valider les règles.