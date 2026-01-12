---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.667142'
id: fb629e9b-655f-4db8-b54e-4d610cced8c4
title: doc-fb629e9b-655f-4db8-b54e-4d610cced8c4
---

📁 AiAgent.java
package org.example.mcp_client.agents;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.tool.ToolCallbackProvider;
import org.springframework.stereotype.Service;

@Service
public class AiAgent {
private ChatClient  chatClient;