---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.845231'
id: eb8ff92e-b4f6-4b31-a7a2-c15bf3168ad0
title: doc-eb8ff92e-b4f6-4b31-a7a2-c15bf3168ad0
---

```rb
# Objectif: chiffrer un texte par décalage (César), casse respectée
def caesar_cipher(input, shift)
  return "" unless input.is_a?(String) && shift.is_a?(Integer)
  shift %= 26
  input.chars.map do |ch|
    if ch =~ /[A-Z]/
      (((ch.ord - 65 + shift) % 26) + 65).chr
    elsif ch =~ /[a-z]/
      (((ch.ord - 97 + shift) % 26) + 97).chr
    else
      ch
    end
  end.join
end
```

```rb
# Objectif: choisir achat/vente maximisant le profit, vente après achat
def day_trader(prices)
  return [] unless prices.is_a?(Array) && prices.all? { |x| x.is_a?(Numeric) }
  min_price = Float::INFINITY
  min_idx = 0
  best = [0, 0, 0] # profit, buy_idx, sell_idx
  prices.each_with_index do |p, i|
    if p < min_price
      min_price = p
      min_idx = i
    end
    profit = p - min_price
    best = [profit, min_idx, i] if profit > best[0]
  end
  best[0] > 0 ? [best[1], best[2]] : [0, 0]
end
```