# Grow a Verity — Development Plan

## Goal

Build Grow a Verity so that a natural-language request to ChatGPT becomes a game change without the user needing to run commands or keep a PC/Roblox Studio online.

## Target pipeline

ChatGPT
→ GitHub source
→ GitHub Actions
→ Rojo
→ Roblox .rbxl
→ Roblox Open Cloud
→ Live Place

GitHub is the source of truth.

## Current status

- GitHub repository: growalovety/grow-a-verity
- Universe ID: 10768994585
- Place ID: 103739066237284
- Roblox Open Cloud publishing: working
- GitHub Actions: working
- Rojo 7.7.1 cloud build: working
- Automatic build + publish: working
- Local bridge: working as an earlier prototype, but not required for the cloud pipeline
- PC/Roblox Studio requirement for deployment: removed

## Current game source

The cloud-build project currently creates:
- 64x64 grass baseplate
- SpawnLocation
- Classic Verity
- Yellow SmoothPlastic spherical Verity
- Common rarity attribute
- classic style attribute

## Development roadmap

### 1. Core game foundation
- Player spawning
- Currency / cash system
- Verity collection system
- Inventory
- Basic UI
- Save/load data

### 2. Grow gameplay
- Planting / spawning Verities
- Growth stages
- Rarity system
- Mutations / variants
- Collection progression

### 3. Economy
- Shop
- Buying and selling
- Prices
- Currency rewards
- Upgrade systems

### 4. World
- Farm / plot system
- NPCs
- Interactive objects
- Areas and progression
- Decorations

### 5. Multiplayer
- Player-owned plots
- Server-authoritative gameplay
- Trading / player interaction where appropriate
- Anti-exploit validation

### 6. Polish
- Animations
- Effects
- Sounds
- UI polish
- Mobile-friendly controls
- Performance optimization

### 7. Automation
Every approved source change should:
1. Commit to GitHub.
2. Trigger GitHub Actions.
3. Build with Rojo.
4. Produce the Roblox place.
5. Publish through Roblox Open Cloud.
6. Keep GitHub as the reproducible source of truth.

## Rule for future changes

Do not manually edit the live Roblox place as the primary workflow.

Implement game changes in the GitHub source first, then let the automated build/publish pipeline deploy them.
