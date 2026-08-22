# Project Guidelines

## Architecture

- This repository is the `recording_studio_pwa` Rails mountable engine for a Recording Studio Progressive Web App host shell.
- Preserve engine namespace isolation under `RecordingStudioPwa`.
- Treat `docs/gem_template/` as architectural reference material from the original template. For current addon workflow, prefer the top-level README and the dummy app.
- Keep changes small and scoped. Do not invent PWA features (manifest, service worker, layouts, slice API) unless the task asks for them.

## UI Conventions

- FlatPack is the default UI system for this repo.
- The approved UI reference is the live FlatPack demo app at https://flatpack.bowerbird.io/ when you need to inspect current shared components and patterns.
- Start with the FlatPack demo app's table of components to quickly discover available UI building blocks before inventing custom markup.
- When editing ERB views, prefer `render FlatPack::...` components over custom HTML when an equivalent component exists.
- Prefer standardized and testable FlatPack ViewComponents over one-off ERB markup or custom JavaScript.
- Treat user-provided FlatPack demo URLs as task context and use them to guide implementation, explanation, or planning.
- Keep custom markup limited to semantic wrappers or content that FlatPack does not cover.
- In Codespaces or other restricted environments, the user may need to enable access to that URL before you can inspect it.
- If the FlatPack demo app is not reachable, clearly say that access to that URL is unavailable and ask the user to enable access or provide sanitized screenshots, copied markup, or component details instead of guessing.
- Keep FlatPack's `rounded` theme on the `<html>` element. Do not copy or fork Recording Studio's default layout.

## Testing

- The standard root validation command is `bundle exec rake test` from the repository root.
- If a change affects dummy app boot, assets, or migrations, also validate the dummy app setup the same way CI does.
- Add focused regression tests for engine hooks, generators, Recording Studio integration points, and host UX changes.

## Repo Conventions

- Keep internal dependency assumptions intact unless the request explicitly asks to change private gem infrastructure.
- Update docs when addon behavior or setup steps change.
- Prefer existing generator, service, and hook patterns over introducing a parallel abstraction.
