# Grow a Verity

Local AI-to-Roblox development pipeline for the original Verity farming/collection game.

## Repository layout

- `bridge/` — localhost command bridge
- `plugin/` — Roblox Studio plugin
- `roblox/` — game-side Luau systems
- `docs/` — command and TODO documentation
- `tests/` — project tests

## Roblox Studio plugin installation

The Studio plugin is `plugin/VerityBuilderPlugin.lua`.

1. In Roblox Studio, open **Plugins → Plugins Folder**.
2. Copy **VerityBuilderPlugin.lua itself** directly into that folder.
3. Do not copy the `plugin` directory, `bridge`, `docs`, `tests`, or `roblox` directories into the Studio Plugins folder.
4. Restart Roblox Studio.
5. The **Verity Builder** toolbar button should appear.

Expected Windows layout:

```text
%LOCALAPPDATA%\Roblox\Plugins\
└── VerityBuilderPlugin.lua
```

Roblox's current documentation confirms that local plugin scripts can be saved into the local Plugins directory and run by Studio. citeturn0search6turn0search5

## Bridge

From `bridge/`:

```bash
npm install
npm start
```

Default address:

```text
http://127.0.0.1:47821
```

The plugin's **TEST CONNECTION** button checks `GET /health`.

## Current connection flow

```text
ChatGPT / AI
      ↓
localhost bridge
      ↓
Roblox Studio plugin
      ↓
Roblox Studio
```

The bridge accepts only explicitly supported commands; it does not execute arbitrary operating-system commands.
