---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.841861'
id: ce5dd882-e84b-4aba-911b-ed5aaaf418f0
title: doc-ce5dd882-e84b-4aba-911b-ed5aaaf418f0
---

### ✍️ Snippets essentiels
```rb
# Objectif: entité case générique avec position et contenu
class BoardCase
  attr_accessor :pos, :value # pos: "A1", value: " " | "X" | "O"
  def initialize(pos, value = " "); @pos = pos; @value = value; end
  def empty? = value == " "
end
```
```rb
# Objectif: plateau 3x3 + logique de victoire
class Board
  WIN_LINES = [%w[A1 A2 A3], %w[B1 B2 B3], %w[C1 C2 C3],
               %w[A1 B1 C1], %w[A2 B2 C2], %w[A3 B3 C3],
               %w[A1 B2 C3], %w[A3 B2 C1]]
  attr_reader :cells, :turn_count
  def initialize
    @cells = %w[A1 A2 A3 B1 B2 B3 C1 C2 C3].map { BoardCase.new(_1) }
    @turn_count = 0
  end
  def [](pos) = cells.find { _1.pos == pos }
  def play!(pos, symbol)
    raise ArgumentError, "invalid" unless valid_move?(pos)
    self[pos].value = symbol; @turn_count += 1
  end
  def valid_move?(pos) = (c = self[pos]) && c.empty?
  def winner