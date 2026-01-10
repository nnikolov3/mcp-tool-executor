# Nexus

**Nexus** is a high-performance, Zig-based Design Partner and local agent orchestrator. It serves as the primary intelligence interface for the book-to-audio project, managing workspace context and providing a robust REPL for system-wide design and execution.

## Overview

Unlike standard LLM interfaces, Nexus is built with "Epistemic Humility" and a "Manifesto of Truth" at its core. It performs dynamic **Reality Scans** of the workspace to ensure its internal state matches the actual code, logs, and configuration on disk. It maintains a local SQLite-backed history to preserve context across sessions.

## Key Features

- **Zig-Powered Performance**: Built with Zig 0.15 for maximum efficiency and memory safety.
- **Reality Scanner**: Dynamically analyzes the workspace to build a high-fidelity context payload for the LLM.
- **Local History**: Persistent session tracking using a local SQLite database (`GEMINI_HISTORY.db`).
- **Standard Mandate Enforcement**: Infuses every interaction with the project's core values (LOVE, CARE, HONESTY, etc.) and technical standards.
- **Tool-Calling Integration**: Supports structured JSON blocks for executing shell commands and other system tools.
- **Color-Coded REPL**: A professional CLI interface with real-time feedback and state tracking.

## Requirements

- **Zig**: 0.15.0+
- **SQLite3**: Linkable system library for history management.
- **Environment**: `GEMINI_API_KEY` must be set in your shell environment.
- **Global Mandate**: Expects `~/.gemini/GEMINI.md` to exist.

## Configuration

Nexus primarily relies on the project's global mandate and local directory scanning. Key paths are:
- **Global Mandate**: `~/.gemini/GEMINI.md`
- **History DB**: `/home/niko/development/GEMINI_HISTORY.db`
- **Templates**: `~/.gemini/templates`

## Getting Started

### Building

```bash
zig build
```

### Running

```bash
zig build run
```
Or directly:
```bash
./zig-out/bin/nexus
```

## Internal Architecture

- `src/main.zig`: Entry point, REPL loop, and service orchestration.
- `src/core/scanner.zig`: Implements the "Reality Scanner" for workspace analysis.
- `src/agent.zig`: Handles communication with the Gemini API.
- `src/db.zig`: SQLite interface for interaction history.
- `src/gemini.zig`: Low-level Gemini API client implementation.
- `src/tools.zig`: Definitions for agent-executable tools.

## The Nexus Mandate

Nexus operates under a strict hierarchy of reality:
1. **The Files & Logs**: The current truth on disk.
2. **The Global Mandate**: The core values and engineering standards.
3. **The History**: Past interactions and decisions.
4. **The Snapshot**: The current session context.
