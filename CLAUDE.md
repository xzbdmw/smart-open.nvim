# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**smart-open.nvim** is a telescope.nvim extension written in Lua that provides intelligent file opening suggestions. It learns from user behavior over time using a self-tuning ranking algorithm that combines fuzzy matching with frecency scoring (frequency + recency).

## Development Commands

```bash
# Linting
make lint                    # Run luacheck on telescope Lua code

# Testing  
make tests                   # Run Plenary-based tests in headless Neovim

# Code formatting
stylua .                     # Format Lua code (uses 2-space indentation)
```

## Architecture

### Core Components

- **Telescope Extension** (`lua/telescope/_extensions/smart_open.lua`): Main extension entry point that registers with telescope
- **Database Layer** (`dbclient.lua`): SQLite3 interface for persistent storage of file access patterns and weights
- **Ranking Algorithm** (`picker.lua`, `weights.lua`): Multi-factor scoring system including fuzzy matching, frecency, buffer status, directory proximity
- **History Management** (`history.lua`): Tracks file access patterns with Mozilla's frecency algorithm
- **Finder Logic** (`finder/`): Core file discovery and ranking implementation
- **Display Layer** (`display/`): Path formatting and result presentation

### Key Design Patterns

1. **Self-Tuning Weights**: Algorithm adjusts scoring weights based on user selections, especially when non-top results are selected
2. **Multi-Source Suggestions**: Combines current working directory files, git files, open buffers, and file history
3. **Special File Handling**: Treats `index.js` and `init.lua` specially by including parent directory in matching for better searchability
4. **Performance Optimization**: Multi-threading support for matching algorithms in `matching/multithread/`

### Database Schema

Uses SQLite3 to store:
- File access timestamps and frecency scores
- Dynamic scoring weights that adapt to user behavior  
- File records with cleanup based on frecency decay

## Configuration Structure

- **Default Config** (`default_config.lua`): Extensive ignore patterns, match algorithm settings, display options
- **Match Algorithms**: Supports both `fzy` and `fzf` with optional native implementations
- **Ignore Patterns**: Comprehensive list excluding binary files, build artifacts, common temporary files

## Testing

- Uses Plenary.nvim testing framework
- Tests located in `lua/tests/`
- Run with `make tests` (executes in headless Neovim)
- Current test coverage focuses on path formatting and display logic

## Dependencies

**Required:**
- Neovim 0.6+
- telescope.nvim
- sqlite.lua (Lua SQLite binding)
- ripgrep (for file scanning)
- sqlite3 (system dependency)

**Optional:**
- nvim-web-devicons (file icons)
- telescope-fzy-native.nvim or telescope-fzf-native.nvim (performance)

## Code Style

- 2-space indentation (configured in stylua.toml)
- Uses luacheck for linting telescope extension code
- Follow existing patterns for telescope extensions and Lua modules