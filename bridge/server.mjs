import http from "node:http";
import crypto from "node:crypto";

const HOST = "127.0.0.1";
const PORT = Number(process.env.PORT || 47821);
const REPO = process.env.VERITY_COMMAND_REPO || "growalovety/grow-a-verity";
const BRANCH = process.env.VERITY_COMMAND_BRANCH || "main";
const POLL_MS = Number(process.env.VERITY_GITHUB_POLL_MS || 2000);
const RAW_BASE = `https://raw.githubusercontent.com/${REPO}/${BRANCH}`;
const QUEUE_INDEX = process.env.VERITY_QUEUE_INDEX || "commands/pending/index.json";
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

async function rawJson(path) {
  const cleanPath = path.replace(/^\/+/, "");
  const url = RAW_BASE + "/" + cleanPath.split("/").map(encodeURIComponent).join("/") + "?t=" + Date.now();
  const response = await fetch(url, {
    headers: {
      "Accept": "application/json",
      "User-Agent": "verity-builder-bridge",
      "Cache-Control": "no-cache",
    },
  });
  if (!response.ok) throw new Error("raw GitHub HTTP " + response.status);
  return response.json();
}

async function pollGitHub() {
  const now = Date.now();
  if (now - lastPoll < POLL_MS) return;
  lastPoll = now;

  try {
    const index = await rawJson(QUEUE_INDEX);
    const files = Array.isArray(index) ? index : (Array.isArray(index.commands) ? index.commands : []);

    for (const entry of files) {
      const fileName = typeof entry === "string" ? entry : entry.file;
      if (!fileName || !fileName.endsWith(".json") || fileName.endsWith("/index.json")) continue;

      const key = typeof entry === "string" ? fileName : (entry.sha || entry.id || fileName);
      if (seen.has(key)) continue;

      const payload = await rawJson(fileName);
      const command = validate(payload);
      const id = String(payload.id || fileName.split("/").pop().replace(/\.json$/, ""));

      if (seen.has(id)) continue;

      seen.add(key);
      seen.add(id);
      queue.push({ id, command, source: fileName, receivedAt: new Date().toISOString() });
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
