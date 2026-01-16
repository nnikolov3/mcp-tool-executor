# Tool Executor

**Tool Executor** is a high-performance, Zig-powered service providing atomic file operations and agent coordination. It serves as the high-integrity execution engine for the Gemini CLI and other AI agents within the book-to-audio workspace.

## Architecture

The service uses a **Networked Bridge** architecture for maximum stability and performance:
1. **Zig Backend**: A high-performance HTTP server (port `9091`) that performs atomic file operations and manages the SQLite-backed agent coordination database.
2. **Python MCP Server**: A FastMCP wrapper that exposes the backend tools via the Model Context Protocol.

## Key Features

- **High Integrity**: Enforces mandatory project headers (`GEMINI.md` standards) on all code modifications.
- **Reliability**: Uses atomic renames and automatic backups (`.bak`) for all file writes to prevent data corruption.
- **Agent Coordination**: Provides a persistent, searchable database for multi-agent synchronization.
- **Git Automation**: Automated commit message generation using Gemini, following strict project templates.
- **Performance**: Built with Zig 0.15.2 for near-instant execution and a minimal memory footprint.

## 🛡️ Alignment with Project Standards

This service is the primary enforcer of the **Manifesto of Truth**:
- **Whole Words Only**: Naming conventions are strictly explicit (e.g., `expected_replacements`, `file_path`).
- **Care**: Enforces the 14-value header on all source files and creates backups before every write.
- **Truth**: The agent coordination database provides an undeniable history of intent and action.

## Available Tools (via MCP)

- `tool_executor__read_file`: Securely reads file content.
- `tool_executor__write_file`: Writes content with header enforcement and backups.
- `replace_whole_word`: Precise, boundary-aware text replacement.
- `agent_commit`: Generates and applies high-integrity commit messages.
- `agent_push`: Securely pushes local commits.
- `update_agents_db`: Logs agent intent, status, and semaphores.
- `read_agents_db`: Retrieves recent coordination history.

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

---
*Built with ❤️, Craftsmanship, and Discipline.*
