---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.541103'
id: e9dc097f-c774-4fb2-b357-ca32af6fb8e8
title: doc-e9dc097f-c774-4fb2-b357-ca32af6fb8e8
---

McpSchema.Content content = result.content().get(0);
                System.out.println(content);
                if (content.type().equals("text")) {
                    McpSchema.TextContent textContent = (McpSchema.TextContent) content;
                    System.out.println(textContent.text());
                }
            });
        };
    }
📷 Resultat d'excecution