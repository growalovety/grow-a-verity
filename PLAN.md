# Grow a Verity — Development Plan

## Goal

Build Grow a Verity so a natural-language request to ChatGPT becomes a game change without the user needing to run commands or keep a PC/Roblox Studio online.

## Pipeline

ChatGPT → GitHub source → GitHub Actions → Rojo → Roblox .rbxl → Roblox Open Cloud → Live Place

GitHub is the source of truth.

## Current status

- GitHub source: active
- Rojo 7.7.1 cloud build: working
- GitHub Actions: working
- Roblox Open Cloud publishing: working
- Automatic build + publish: working
- PC/Roblox Studio required for deployment: no

## Implemented

### Variant system v1
The first four core variants are defined in source:
- **Verity** — yellow, Common, helpful, income 1
- **Falsity** — blue, Uncommon, deceptive, income 3
- **Cruelty** — red/dark red, Rare, aggressive, income 6
- **Lovity** — pink, Epic, affectionate, income 10

Each variant has a reusable definition containing:
- Name
- Color
- Rarity
- Personality
- Income

The source also generates a simple face and floating name/rarity display.

The color/name/personality concept is based on current web research into fan-created Verity variants. These variants are not treated as an official canonical franchise.

## Next development steps

### 1. Variant gameplay layer
- Variant registry
- Spawn/roll system
- Rarity probabilities
- Variant ownership
- Collection entries
- Variant-specific income
- Clean model factory

### 2. Player progression
- Player cash
- Passive income
- Collection UI
- Inventory
- Basic save/load with DataStore

### 3. Plot system
- One plot per player
- Place owned Verities on the plot
- Plot boundaries
- Repositioning
- Upgrade slots

### 4. Growth system
- Plant/spawn a Verity
- Growth timer
- Growth stages
- Final variant
- Mutation chances

### 5. Economy
- Shop
- Buying variants
- Selling variants
- Upgrade costs
- Rarity-based pricing

### 6. UI
- Cash counter
- Inventory/collection
- Shop UI
- Variant information
- Notifications
- Mobile layout

### 7. World and content
- NPCs
- Areas
- Decorations
- Ambient effects
- More variants
- Events

### 8. Multiplayer and security
- Server-authoritative purchases
- Server-authoritative spawning
- RemoteEvent validation
- Anti-exploit checks
- Rate limits

### 9. Polish
- Animations
- VFX
- Sounds
- Better models/faces
- Performance optimization
- Mobile controls

## Automation rule

Future game changes are implemented in GitHub source first. A successful GitHub Actions build publishes the resulting place through Roblox Open Cloud. Do not use manual Studio edits as the primary source of truth.
