# AGENTS.md

## Repo Purpose

This repository contains the Hugo source for `martintrojer.github.com`.

## Source Of Truth

- The `master` branch is the source branch.
- Do not use the old two-branch Hugo workflow.
- Do not commit generated site output from `public/`.
- GitHub Actions builds and deploys the site to GitHub Pages.

## Local Development

- Run the local dev server with `hugo server`.
- Run a production build check with `hugo build --gc --minify`.
- If cache writes fail in a restricted environment, use `--cacheDir /tmp/hugo_cache`.

## Repo Layout

- `content/` contains posts and pages.
- `static/` contains static assets copied directly into the built site.
- `themes/smol/` contains the active Hugo theme.
- `.github/workflows/hugo.yaml` contains the Pages deployment workflow.
- `public/` is a build artifact and should remain uncommitted.

## Deployment

- Push to `master` to trigger deployment.
- In GitHub repository settings, Pages must be configured to deploy from `GitHub Actions`.

## Editing Guidance

- Prefer changing source files under `content/`, `static/`, `themes/`, and `hugo.yaml`.
- Avoid editing generated HTML, XML, or copied assets at the repo root.
- Preserve the existing Hugo structure unless there is a clear migration reason.
- Keep changes minimal and verify with a local Hugo build when practical.
