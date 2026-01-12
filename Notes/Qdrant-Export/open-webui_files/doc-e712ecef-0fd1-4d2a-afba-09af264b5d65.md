---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.844768'
id: e712ecef-0fd1-4d2a-afba-09af264b5d65
title: doc-e712ecef-0fd1-4d2a-afba-09af264b5d65
---

# exo_08: compte à rebours
n = gets.to_i
n.downto(0) { |i| puts i }

# exo_09: lister les années jusqu'à aujourd'hui
y = gets.to_i
(Time.now.year).downto(y).to_a.reverse.each { |a| puts a }

# exo_10: afficher année + âge correspondant
y = gets.to_i
(0..(Time.now.year - y)).each do |age|
  puts "#{y + age} : tu avais #{age} ans"
end

# exo_11: "Il y a X ans tu avais Y ans"
age_actuel = gets.to_i
age_actuel.downto(0).each do |age|
  x = age_actuel - age
  puts "Il y a #{x} ans, tu avais #{age} ans"
end

# exo_12: cas moitié
age_actuel = gets.to_i
age_actuel.downto(0).each do |age|
  x = age_actuel - age
  if x == age
    puts "Il y a #{x} ans, tu avais la moitié de l'âge que tu as aujourd'hui"
  else
    puts "Il y a #{x} ans, tu avais #{age} ans"
  end
end

# exo_13: générer 50 emails
emails = (1..50).map { |i| sprintf("prenom.nom.%02d@email.fr", i) }

# exo_14: afficher emails pairs
emails.each { |e| puts e if e.match?(/\.(\d\d)@/) && $1.to_i.even? }