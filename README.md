# martintrojer.github.com

Hugo source for the blog, deployed to GitHub Pages with GitHub Actions.

## Local development

Run the dev server:

```bash
hugo server
```

Build the production site locally:

```bash
hugo build --gc --minify
```

The generated output goes to `public/` and is not committed.

## Deployment

Push to `master`:

```bash
git add .
git commit -m "..."
git push
```

GitHub Actions builds the site and deploys it to GitHub Pages.

Repository setting required:

1. Open `Settings` -> `Pages`
2. Set `Source` to `GitHub Actions`

## Branches

This repo now uses a single source branch. The old `hugo` branch is no longer needed after this migration is pushed and Pages is deploying from Actions successfully.
