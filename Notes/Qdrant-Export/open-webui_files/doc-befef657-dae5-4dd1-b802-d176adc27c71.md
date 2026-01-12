---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.839611'
id: befef657-dae5-4dd1-b802-d176adc27c71
title: doc-befef657-dae5-4dd1-b802-d176adc27c71
---

```rb
# Bloc et yield
def with_logging
  puts "[start]"
  result = yield if block_given?
  puts "[end]"
  result
end
```

```rb
# Passer un bloc comme Proc
def runner(&block)
  block.call("INPUT")
end
```

```rb
# lambda vs proc (retour)
L = ->(x) { x * 2 }   # return local au lambda
P = Proc.new { |x| x * 2 }
```

```rb
# Méthodes pures vs avec effets
def normalize(items) # pure
  items.map { |x| x.to_s.strip.downcase }
end
```

```rb
# Orchestration
def perform
  items = ["A", "B", "C"]
  clean = normalize(items)
  with_logging { clean.join(",") }
end
perform
```

### 🔗 Relations / Composition
- `perform` compose [[Service]] d'entrée, [[Module]] de traitement, [[Component]] d'I/O.
- Petites méthodes spécialisées branchées en pipeline.
- Entrées → traitement → sortie claire. Pas d'état global caché.

### 🧪 Test / Validation
```bash
# Démarrer RSpec et lancer un test ciblé
rspec --init
rspec spec/utils_spec.rb
```