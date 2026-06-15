# DOX framework

- DOX is highly performant AGENTS.md hierarchy installed here
- Agent must follow DOX instructions across any edits

## Core Contract

- AGENTS.md files are binding work contracts for their subtrees
- Work products, source materials, instructions, records, assets, and durable docs must stay understandable from the nearest applicable AGENTS.md plus every parent AGENTS.md above it

## Read Before Editing

1. Read the root AGENTS.md
2. Identify every file or folder you expect to touch
3. Walk from the repository root to each target path
4. Read every AGENTS.md found along each route
5. If a parent AGENTS.md lists a child AGENTS.md whose scope contains the path, read that child and continue from there
6. Use the nearest AGENTS.md as the local contract and parent docs for repo-wide rules
7. If docs conflict, the closer doc controls local work details, but no child doc may weaken DOX

Do not rely on memory. Re-read the applicable DOX chain in the current session before editing.

## Update After Editing

Every meaningful change requires a DOX pass before the task is done.

Update the closest owning AGENTS.md when a change affects:

- purpose, scope, ownership, or responsibilities
- durable structure, contracts, workflows, or operating rules
- required inputs, outputs, permissions, constraints, side effects, or artifacts
- user preferences about behavior, communication, process, organization, or quality
- AGENTS.md creation, deletion, move, rename, or index contents

Update parent docs when parent-level structure, ownership, workflow, or child index changes. Update child docs when parent changes alter local rules. Remove stale or contradictory text immediately. Small edits that do not change behavior or contracts may leave docs unchanged, but the DOX pass still must happen.

## Hierarchy

- Root AGENTS.md is the DOX rail: project-wide instructions, global preferences, durable workflow rules, and the top-level Child DOX Index
- Child AGENTS.md files own domain-specific instructions and their own Child DOX Index
- Each parent explains what its direct children cover and what stays owned by the parent
- The closer a doc is to the work, the more specific and practical it must be

## Child Doc Shape

- Create a child AGENTS.md when a folder becomes a durable boundary with its own purpose, rules, responsibilities, workflow, materials, or quality standards
- Work Guidance must reflect the current standards of the project or user instructions; if there are no specific standards or instructions yet, leave it empty
- Verification must reflect an existing check; if no verification framework exists yet, leave it empty and update it when one exists

Default section order:
- Purpose
- Ownership
- Local Contracts
- Work Guidance
- Verification
- Child DOX Index

## Style

- Keep docs concise, current, and operational
- Document stable contracts, not diary entries
- Put broad rules in parent docs and concrete details in child docs
- Prefer direct bullets with explicit names
- Do not duplicate rules across many files unless each scope needs a local version
- Delete stale notes instead of explaining history
- Trim obvious statements, repeated rules, misplaced detail, and warnings for risks that no longer exist

## Closeout

1. Re-check changed paths against the DOX chain
2. Update nearest owning docs and any affected parents or children
3. Refresh every affected Child DOX Index
4. Remove stale or contradictory text
5. Run existing verification when relevant
6. Report any docs intentionally left unchanged and why

## User Preferences

When the user requests a durable behavior change, record it here or in the relevant child AGENTS.md

## Project Context

CPTO exposes HTTP and SOCKS proxy ports that route all proxied traffic through a containerized OpenVPN client. It ships two runtime targets:

**Docker Compose** — four services: openvpn (network namespace owner), tinyproxy (HTTP proxy), srelay (SOCKS4/5 proxy), haproxy (public TCP frontend). Runtime config lives in `.env` (gitignored); `.env.example` is the template. `compose.sh` wraps `docker compose` with `--project-name=cpto`. `test.sh` verifies proxy routing end-to-end.

Key cross-component rule (Compose): tinyproxy and srelay share openvpn's network namespace (`network_mode: service:openvpn`). Any port binding changes in those components must be reflected in `haproxy.cfg` and `docker-compose.yaml`.

**Kubernetes** — same three proxy containers run as a multi-container Pod (network namespace shared natively). A Deployment with 3 replicas provides independent VPN tunnel groups; a NodePort Service replaces haproxy. All Kubernetes manifests and `kube.sh` live in `k8s/`. Config in `k8s/configmap.yaml`; credentials in `k8s/secret.yaml` (gitignored; `k8s/secret.example.yaml` is the template). `k8s/kube.sh` wraps `kubectl` with `--namespace=cpto`.

## Project Tooling

- `.claude/commands/push-hub-readmes.md` — slash command (`/push-hub-readmes`) that authenticates with Docker Hub via stored credentials and pushes each container's `README.md` as the `full_description` for its Docker Hub repository

## Child DOX Index

- [`haproxy/AGENTS.md`](haproxy/AGENTS.md) — TCP frontend; published host ports; routes to tinyproxy and srelay via openvpn hostname
- [`k8s/AGENTS.md`](k8s/AGENTS.md) — Kubernetes manifests and kube.sh wrapper; deployment, service, configmap, namespace, and secret template
- [`openvpn/AGENTS.md`](openvpn/AGENTS.md) — VPN client; owns the shared network namespace; readiness check before tunnel start
- [`srelay/AGENTS.md`](srelay/AGENTS.md) — SOCKS4/5 proxy; multi-stage build from source; runs in openvpn namespace
- [`tinyproxy/AGENTS.md`](tinyproxy/AGENTS.md) — HTTP proxy; runs in openvpn namespace