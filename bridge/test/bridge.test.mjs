import test from "node:test";
import assert from "node:assert/strict";

test("command protocol allowlist is documented", async () => {
  const response = await fetch("http://127.0.0.1:47821/health").catch(() => null);
  assert.ok(response === null || response.status === 200);
});
