# Contributing

Thanks for contributing! Please follow these guidelines to make contributions easy to review and integrate.

## Getting started
- Fork the repository and create a branch using kebab-case: `feature/my-change`.
- Run tests locally: `mvn -q -DskipTests=false test` or `./mvnw test`.
- Use Java 21 (see `pom.xml` <properties>).

## Issue and PR process
- Use the provided ISSUE templates for bugs, features, docs or performance issues.
- Link relevant spec/plan files (e.g., `specs/031-workflow-automation/plan.md`) in your issue and PR.
- For larger work, open an issue first to discuss scope.

## Branching & commits
- Keep changes small and focused. One logical change per pull request.
- Commit messages should follow: `Type(scope): Short description` (e.g., `Fix(build): correct plugin configuration`).
- Add `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>` if AI assisted.

## Pull requests
- Include a clear summary, related issue/spec, and checklist in the PR body.
- Ensure CI passes and tests are added or updated.
- Document breaking changes in the changelog or PR description.

## Code style
- Follow existing project conventions. Keep methods small and prefer descriptive names.
- Prefer immutability and null-safety. Add unit tests for behavior.

## Testing
- Add unit and integration tests where applicable. Use Testcontainers for DB-backed tests.

## Speckit and automation
- When changes implement a spec, reference the `specs/...` file and add any new tasks to `specs/.../tasks.md`.
- Use structured templates so automation can extract tasks and metadata.

## Security and sensitive information
- Do not commit secrets, keys, or passwords. Use environment variables or secrets management.
- Report vulnerabilities via `SECURITY.md`.

## Thank you
Thanks for helping improve the project. Maintain a collaborative and respectful tone in reviews.