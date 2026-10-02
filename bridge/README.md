# Direct ChatGPT → Roblox Studio command path

The bridge now polls the public GitHub repository for approved command files under `commands/pending/`.

Flow:

ChatGPT/tooling → GitHub `commands/pending/*.json` → local bridge → Studio plugin → Roblox Studio

The bridge still supports the local `POST /command` endpoint for development/testing.

## Run

```bash
npm install
npm start
```

Keep the terminal running while Studio is open.

## Studio

Set the plugin bridge URL to:

```
http://127.0.0.1:47821
```

Then press **TEST CONNECTION** and **START LISTENING**.

## Security model

Only a fixed allowlist of builder commands is accepted. The bridge never executes shell commands, JavaScript from GitHub, or arbitrary code. GitHub files are interpreted only as JSON command payloads.

For a production deployment, use a private command channel/authenticated relay instead of a public repository queue.
