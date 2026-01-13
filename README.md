# Tool Executor

**Tool Executor** is a high-performance, Zig-powered service providing atomic and reliable file operations and agent coordination. It serves as the high-integrity execution engine for the Gemini CLI and other AI agents in the workspace.

## Architecture

The service uses a **Networked Bridge** architecture for maximum stability:
1. **Zig Backend**: A high-performance HTTP server (`port 9091`) that performs atomic file operations and manages the SQLite-backed agent coordination database.
2. **Python MCP Server**: A thin FastMCP wrapper that exposes the backend tools via the Model Context Protocol.

## Key Features

- **High Integrity**: Enforces mandatory project headers (`GEMINI.md` standards) on all code modifications.
- **Reliability**: Uses atomic renames and automatic backups (`.bak`) for all file writes.
- **Agent Coordination**: Provides a persistent, searchable database (`AGENTS_CHAT.db`) for multi-agent synchronization, replacing manual markdown logs.
- **Git Automation**: Automated commit message generation using Gemini, following the project's strict template standards.
- **Performance**: Built with Zig 0.15.2 for near-instant execution and minimal memory footprint.

## Available Tools (via MCP)

- `tool_executor__read_file(path)`: Securely reads file content (prefixed to avoid collision with built-in).
- `tool_executor__write_file(path, content)`: Writes content with header enforcement and backups (prefixed to avoid collision).
- `replace_whole_word(path, old, new)`: Precise, boundary-aware text replacement.
- `replace_text(path, old, new)`: Global text replacement.
- `agent_commit(path, context)`: Generates and applies a high-integrity commit message via Gemini.
- `agent_push(path)`: Pushes local commits to the remote repository.
- `update_agents_db(...)`: Logs agent intent, status, and semaphores.
- `read_agents_db(limit)`: Retrieves recent coordination history.
- `search_agents_db(query)`: Searches history for specific tasks or agents.

## Getting Started

### Building
```bash
zig build
```

### Running the Backend
```bash
./zig-out/bin/tool-executor
```

### Starting the MCP Server
```bash
python3 tool_executor_tool_mcp_server.py
```

## Engineering Standards

This repository adheres to the **Manifesto of Truth**:
- **Whole Words Only**: No abbreviations in naming.
- **Implicit Assumptions are Failures**: State is declared and verified.
- **Love, Care, and Craftsmanship**: Every line is written for long-term health.
