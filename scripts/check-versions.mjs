#!/usr/bin/env node
// Lockstep guard (decision D4): tokens and react must share an exact version
// (Changesets keeps them linked), and the Flutter package must share their
// MAJOR. Exact Flutter equality is not required mid-release — Changesets bumps
// npm versions in its own PR after the Flutter bump lands.
// Run: `node scripts/check-versions.mjs`
import { readFileSync } from "node:fs";

const pkg = (p) => JSON.parse(readFileSync(new URL(p, import.meta.url), "utf8"));
const tokens = pkg("../packages/tokens/package.json").version;
const react = pkg("../packages/react/package.json").version;
const pubspec = readFileSync(new URL("../packages/flutter/pubspec.yaml", import.meta.url), "utf8");
const flutter = pubspec.match(/^version:\s*(\S+)/m)?.[1];

let fail = 0;
if (tokens !== react) {
  fail++;
  console.error(`✗ @aeros-core/tokens (${tokens}) and @aeros-core/react (${react}) must be identical (linked).`);
}
const major = (v) => String(v).split(".")[0];
if (!flutter || major(flutter) !== major(react)) {
  fail++;
  console.error(`✗ aeros_design_system (${flutter}) must share the react major (${react}).`);
}
if (fail) process.exit(1);
console.log(`✓ Versions lockstep — tokens/react ${react}, flutter ${flutter} (same major).`);
