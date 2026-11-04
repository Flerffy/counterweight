# Counterweight — Programming Handoff

**Repository:** https://github.com/Flerffy/counterweight

**Engine:** Godot 4.6

**Lead Programmer:** Erik

**Co-Programmer:** Flocos

## 1. Development Responsibilities

Your initial priorities are:

- [ ] Clone the repository and verify that the project runs correctly.
- [ ] Review the existing code for bugs, architectural problems, and maintainability.
- [ ] Test weight transfers, carrying, pressure plates, doors, and room reset.
- [ ] Investigate whether heavy blocks can bypass carrying restrictions through pushing.
- [ ] Create a second playable puzzle room using the existing components.
- [ ] Expand the README with setup instructions, controls, and system documentation.

Please avoid unnecessary rewrites or additional mechanics until the current prototype has been independently validated.

## 2. Repository Workflow

We'll use a feature-branch and Pull Request workflow. The `main` branch represents the latest reviewed, stable version of Counterweight.

**Do not commit or push directly to `main`.**

### A. Clone the repository

If you haven't already cloned it:

`git clone https://github.com/Flerffy/counterweight.git`

`cd counterweight`

### B. Create a working branch

Before starting new work, update your local `main`:

`git switch main`

`git pull --ff-only origin main`

Create a branch for your task:

`git switch -c feature/your-feature-name`

Use descriptive branch names, such as:

- `feature/puzzle-room-02`
- `fix/carry-collision`
- `docs/project-onboarding`
- `refactor/weight-interaction`

Try to keep each branch focused on one feature, fix, or related group of changes.

### C. Commit your work

Once your changes are complete and tested:

`git add .`

`git commit -m "Describe the changes made"`

`git push -u origin feature/your-feature-name`

Use meaningful commit messages that explain what was implemented or fixed.

### D. Submit a Pull Request

On GitHub:

1. Open the Counterweight repository.
2. Navigate to **Pull Requests → New Pull Request**.
3. Select `main` as the base branch.
4. Select your feature branch as the comparison branch.
5. Give the PR a descriptive title.
6. Explain what changed, why, and how you tested it.
7. Request Erik's review.

**Do not merge your own Pull Requests.**

I'll inspect the implementation, test it in Godot where applicable, and either approve the changes or request revisions.

### E. Address review feedback

If changes are requested:

1. Return to the same feature branch.
2. Make the requested corrections.
3. Commit and push the changes to that branch.
4. Let me know the PR is ready for another review.

The existing Pull Request updates automatically when you push new commits.

Once the PR passes review, I'll merge it into `main`.

### F. Start the next task

After the previous PR is merged:

`git switch main`

`git pull --ff-only origin main`

Create a fresh branch for your next task.

Avoid starting new features from an outdated branch.

## 3. Coding Standards

We're maintaining readable, documented GDScript throughout the project.

- Scripts should have headers explaining their responsibilities and dependencies.
- Public-facing properties and methods should be documented.
- Explain non-obvious logic and design decisions.
- Use static typing where practical.
- Prefer small, focused components over monolithic scripts.
- Use Godot's existing features before creating custom tools.
- Avoid changing unrelated systems in a feature branch.

Please preserve existing interfaces unless there's a specific reason to change them. Discuss architectural changes with me before implementing them.

## 4. Pull Request Requirements

Before requesting a merge, confirm:

- [ ] Project opens without new errors.
- [ ] New functionality has been tested in Godot.
- [ ] Existing gameplay still works.
- [ ] Relevant scripts are documented.
- [ ] No unnecessary files or generated cache data are committed.
- [ ] Changes are restricted to the intended task.
- [ ] Known limitations are listed in the PR description.

For gameplay changes, screenshots or short recordings are welcome when they make the implementation easier to review.

## 5. Development Philosophy

We're working under a game jam deadline.

Prioritize completing and polishing the existing gameplay over speculative features. If you identify a problem, document how to reproduce it and propose the smallest reasonable solution.

The goal is to keep both programmers productive while preserving a stable, playable `main` branch.

**All changes to `main` require lead programmer review and approval.**
