# Contributing to StarForum

First of all, thank you for your interest in contributing to StarForum ❤️

We welcome all kinds of contributions, including bug fixes, new features, documentation improvements, and design suggestions.

Repository: https://github.com/cubevlmu/StarForum

---

## Development Setup

1. Install Flutter SDK  
https://flutter.dev/docs/get-started/install

2. Clone the repository

git clone https://github.com/cubevlmu/StarForum.git  
cd StarForum

3. Install dependencies

flutter pub get

4. Run the project

flutter run

---

## Branch Strategy

We use a simple branch model:

main   → stable releases  
dev    → active development  

New work should be created from `dev`.

Example branches:

feature/discussion-cache  
feature/login-refactor  
fix/avatar-loading  

---

## Commit Message Convention

Please follow the Conventional Commits format.

type(scope): description

Examples:

feat(discussion): add discussion cache  
fix(login): fix token refresh bug  
refactor(ui): simplify discussion list layout  

Common commit types:

feat      new feature  
fix       bug fix  
refactor  code refactor  
docs      documentation  
style     formatting  
perf      performance improvement  
chore     maintenance  

---

## Pull Request Process

1. Fork the repository
2. Create a branch from `dev`
3. Implement your changes
4. Open a Pull Request

Please make sure:

- The project builds successfully
- Code follows the existing style
- No unrelated changes are included

---

## Good First Issues

If you're new to the project, look for issues labeled:

good first issue

These are beginner-friendly tasks.

---

## Discussions

For ideas, questions, or feature discussions, please use GitHub Discussions instead of opening issues.

---

Thank you for contributing to StarForum!