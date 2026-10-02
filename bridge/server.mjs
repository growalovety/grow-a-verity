import http from "node:http";
import crypto from "node:crypto";

const HOST = "127.0.0.1";
const PORT = Number(process.env.PORT || 47821);
const REPO = process.env.VERITY_COMMAND_REPO || "growalovety/grow-a-verity";
const BRANCH = process.env.VERITY_COMMAND_BRANCH || "main";
const POLL_MS = Number(process.env.VERITY_GITHUB_POLL_MS || 2000);
const MAX_BODY = 16 * 1024;

const ALLOWED = new Set([
  "BUILD_VERITY",
  "CREATE_PART",
  "CREATE_FOLDER",
  "DELETE_OBJECT",
  "GET_GAME_STATE",
]);

const queue = [];
const seen = new Set();
let lastPoll = 0;

function json(res, status, body) {
  const data = JSON.stringify(body);
  res.writeHead(status, {
    "Content-Type": "application/json",
    "Cache-Control": "no-store",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
  });
  res.end(data);
}

function validate(command) {
  if (!command || typeof command !== "object") throw new Error("command must be an object");
  if (!ALLOWED.has(command.command)) throw new Error("unsupported command");
  if (command.name !== undefined && (typeof command.name !== "string" || command.name.length > 80)) {
    throw new Error("invalid name");
  }
  if (command.command === "BUILD_VERITY") {
    if (!command.name) throw new Error("BUILD_VERITY requires name");
    if (command.size !== undefined && (!Number.isFinite(command.size) || command.size < 0.25 || command.size > 100)) {
      throw new Error("invalid size");
    }
  }
  return command;
}

async function githubJson(url) {
  const response = await fetch(url, {
    headers: {
      "Accept": "application/vnd.github+json",
      "User-Agent": "verity-builder-bridge",
    },
  });
  if (!response.ok) throw new Error(`GitHub HTTP ${response.status}`);
  return response.json();
}

async function pollGitHub() {
  const now = Date.now();
  if (now - lastPoll < POLL_MS) return;
  lastPoll = now;

  const api = `https://api.github.com/repos/${REPO}/contents/commands/pending?ref=${encodeURIComponent(BRANCH)}`;

  try {
    const files = await githubJson(api);
    if (!Array.isArray(files)) return;

    for (const file of files) {
      if (file.type !== "file" || !file.name.endsWith(".json") || seen.has(file.sha)) continue;

      const payload = await githubJson(file.download_url);
      const command = validate(payload.command || payload);
      const id = String(payload.id || file.name.replace(/\.json$/, ""));

      if (seen.has(id)) continue;

      seen.add(file.sha);
      seen.add(id);
      queue.push({ id, command, source: file.name, receivedAt: new Date().toISOString() });
    }
  } catch (error) {
    console.error("[github poll]", error.message);
  }
}

setInterval(pollGitHub, 250);
pollGitHub();

const server = http.createServer(async (req, res) => {
  if (req.method === "OPTIONS") return json(res, 204, { ok: true });

  const url = new URL(req.url, `http://${HOST}:${PORT}`);

  if (req.method === "GET" && url.pathname === "/health") {
    return json(res, 200, {
      ok: true,
      service: "verity-bridge",
      githubQueue: `${REPO}@${BRANCH}`,
      queued: queue.length,
    });
  }

  if (req.method === "GET" && url.pathname === "/next") {
    return json(res, 200, { ok: true, item: queue.shift() || null });
  }

  if (req.method === "GET" && url.pathname === "/queue") {
    return json(res, 200, { ok: true, items: queue.slice(0, 50) });
  }

  if (req.method === "POST" && url.pathname === "/command") {
    let body = "";
    req.on("data", chunk => {
      body += chunk;
      if (Buffer.byteLength(body) > MAX_BODY) req.destroy();
    });
    req.on("end", () => {
      try {
        const command = validate(JSON.parse(body));
        queue.push({
          id: crypto.randomUUID(),
          command,
          source: "local",
          receivedAt: new Date().toISOString(),
        });
        json(res, 202, { ok: true, queued: true });
      } catch (error) {
        json(res, 400, { ok: false, error: error.message });
      }
    });
    return;
  }

  return json(res, 404, { ok: false, error: "not found" });
});

server.listen(PORT, HOST, () => {
  console.log(`Verity bridge listening on http://${HOST}:${PORT}`);
  console.log(`GitHub command source: ${REPO}@${BRANCH}`);
});
