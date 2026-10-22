# Skills in this repository

100 skills live in `.agents/skills/`, with symlinks in `.claude/skills/` so Claude Code
discovers them. `skills-lock.json` pins the source and content hash of the 95 installed
through the `skills` CLI; the other 5 were installed by hand from uploads.

| Source | Skills |
|---|---|
| `coreyhaines31/marketingskills` | 49 |
| `charlie947/social-media-skills` | 17 |
| `Leonxlnx/taste-skill` | 13 |
| `anthropics/knowledge-work-plugins` (legal) | 9 |
| `nextlevelbuilder/ui-ux-pro-max-skill` | 7 |
| uploaded bundles and files | 5 |

## Where skills can live, and how far each reaches

This is the part that decides whether a skill is there next time. There are three tiers,
and they are not interchangeable.

### 1. Project level — this repository only

What committing to `.agents/skills/` gives you. Any session working inside a checkout of
this repository sees these skills. A session on a different project does not.

Already done for all 100. Nothing to run.

### 2. User level — every session on one machine

`~/.claude/skills/`. Applies to every project on that machine, not just this one.

```bash
bash scripts/install-skills.sh          # copy
bash scripts/install-skills.sh --link   # symlink, so edits track the repo
bash scripts/install-skills.sh --list   # show state, change nothing
```

**On a cloud container this does not survive.** The container is reclaimed when the session
ends and the home directory goes with it. To make it automatic there, set the environment's
**Setup script** (cloud environment menu in the session title bar → Edit → Setup script) to:

```bash
bash /home/user/client-portal/scripts/install-skills.sh
```

Every new session in that environment then re-installs them at startup.

### 3. Account level — every session, everywhere

Skills uploaded to your claude.ai account sync down into every session automatically, on any
machine and in any project. This is the only tier that genuinely means "all future sessions",
and it is already working for your existing synced skills, which arrive in
`~/.claude/skills/synced/`.

Package any skill here into the upload format:

```bash
bash scripts/package-skills.sh                    # all of them
bash scripts/package-skills.sh copywriting seo-audit   # just these
```

That writes `dist/skills/<name>.skill`, a zip whose root is `<name>/SKILL.md` — the same shape
as a downloaded bundle. Upload at **claude.ai → Settings → Capabilities → Skills**.

Uploading has to be done by you; it cannot be driven from inside a session.

## Platform notes

`higgsfield-motion` and `higgsfield-motion-saas` ship macOS tooling (Swift + AVFoundation +
`afconvert`). `higgsfield-motion` also carries a Linux port in `scripts/linux/`, backed by
ffmpeg and installed by `scripts/setup-linux.sh` under the same tool names — see
`.agents/skills/higgsfield-motion/scripts/linux/README.md`. `higgsfield-motion-saas` has not
been ported.

`higgsfield-motion/scripts/encode` is a prebuilt Mach-O arm64 binary kept from the original
bundle. It is unauditable and runs only on Apple Silicon; `setup.sh` treats it as a fallback
for machines without `swiftc`, and it can be rebuilt from `scripts/encode.swift`.

## Reference material that is not a skill

- `.agents/references/higgsfield-thumbnail-playbook.pdf` — 5 high-CTR thumbnail frameworks.
  Not auto-discovered; point a skill at it or read it directly.
- `.agents/skills/create-ads-with-agents/assets/meta-ads-client-brief.pdf` — blank 8-section
  client intake form, used by that skill's "supplied brief" step.
