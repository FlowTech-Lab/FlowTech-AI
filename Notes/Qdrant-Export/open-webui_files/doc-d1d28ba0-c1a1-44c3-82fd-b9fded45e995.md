---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.842073'
id: d1d28ba0-c1a1-44c3-82fd-b9fded45e995
title: doc-d1d28ba0-c1a1-44c3-82fd-b9fded45e995
---

# Objectif: appeler l'API Completions en POST
require "http"; require "json"
api_key = ENV["OPENAI_API_KEY"]
resp = HTTP.headers(
  "Content-Type" => "application/json",
  "Authorization" => "Bearer #{api_key}"
).post("https://api.openai.com/v1/completions", json: {
  prompt: "Liste 5 parfums de glace en puces",
  max_tokens: 60, temperature: 0.3, model: "babbage-002"
})
text = JSON.parse(resp.body.to_s).dig("choices", 0, "text").to_s.strip
puts text
```