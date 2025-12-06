# Development Methodology

This document describes the development methodology used for the Habit Tracker project, part of the Coursera Mobile App Development Capstone Project.

## Overview

We followed an Agile-inspired workflow with:
- Sprint-based development
- GitHub Issues for tracking
- Feature branch workflow
- Pull Request reviews
- Continuous integration via automated code review

---

## 1. Issue Management

### Creating Issues
Each feature or bug is tracked as a GitHub Issue with:
- **Title**: Clear, action-oriented (e.g., "View Weekly Reports")
- **User Story**: `As a [user], I want [feature], so that [benefit]`
- **Acceptance Criteria**: Numbered list of requirements
- **Story Points**: Effort estimate (1, 2, 3, 5, 8)
- **Priority**: Low, Medium, High

### Labels
| Label | Purpose |
|-------|---------|
| `enhancement` | New features |
| `bug` | Defects to fix |
| `priority: low` | Nice to have |
| `priority: medium` | Standard priority |
| `priority: high` | Critical/blocking |

### Example Issue
```markdown
**User Story:**
As a user, I want to view weekly reports so that I can track my habit progress.

**Acceptance Criteria:**
1. Reports page shows weekly overview
2. Data from habit completion history
3. Accessible from menu

**Priority:** Medium
**Story Points:** 5
```

---

## 2. Sprint Planning

### Sprint Structure
- Each sprint focuses on a specific screen or feature area
- Sprint contains 3-5 related issues
- Total story points: ~11-15 per sprint

### Sprint History
| Sprint | Focus Area | Issues | Total SP |
|--------|------------|--------|----------|
| 1-2 | Authentication & Core | Login, Register, Home, Add Habit | - |
| 3 | Profile Screen | #11, #12, #13, #14 | 11 |
| 4 | Reports Screen | #18, #19, #20 | 13 |
| 5 | Notifications | #21, #22, #23 | 11 |

### Sprint Workflow
1. Review open issues and prioritize
2. Select issues for sprint based on dependencies and priority
3. Create plan document in `.claude/plans/`
4. Implement features
5. Close issues with PR references

---

## 3. Git Workflow

### Branch Strategy
```
main (protected)
  └── feature/[feature-name]
  └── fix/[bug-name]
  └── refactor/[refactor-name]
```

### Branch Naming Convention
| Prefix | Use Case |
|--------|----------|
| `feature/` | New features |
| `fix/` | Bug fixes |
| `refactor/` | Code improvements |
| `docs/` | Documentation updates |

### Commit Messages
Follow conventional commit format:
```
type: short description

Longer description if needed.

Closes #XX
```

Types: `feat`, `fix`, `refactor`, `docs`, `perf`, `test`, `chore`

### Example Workflow
```bash
# 1. Start from main
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/reports-screen

# 3. Make changes, commit
git add .
git commit -m "feat: implement weekly reports chart"

# 4. Push and create PR
git push -u origin feature/reports-screen
gh pr create --title "feat: implement reports screen"

# 5. After merge, clean up
git checkout main
git pull origin main
git branch -d feature/reports-screen
```

---

## 4. Pull Request Process

### PR Structure
```markdown
## Summary
- Bullet points of changes

## Test plan
- [ ] Manual testing steps
- [ ] Verification checklist

Closes #XX, #YY
```

### Code Review
We use Gemini Code Assist for automated PR reviews. For each comment:

| Decision | When to Use |
|----------|-------------|
| **IMPLEMENT** | Valid bug fix or important improvement |
| **DEFER** | Good suggestion but not critical now |
| **DISCARD** | Style preference or over-engineering |

### Merge Strategy
- **Squash and merge**: Combines all commits into one clean commit
- **Delete branch**: After merge, delete the feature branch

---

## 5. Code Organization

### Project Structure
```
lib/
├── core/
│   ├── constants/    # App-wide constants
│   └── theme/        # Theme configuration
├── models/           # Data models
├── screens/          # UI screens
├── services/         # Business logic
└── widgets/          # Reusable widgets
```

### Naming Conventions
| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `home_screen.dart` |
| Classes | PascalCase | `HomeScreen` |
| Variables | camelCase | `habitList` |
| Constants | camelCase | `defaultUsername` |

---

## 6. Documentation

### Required Documentation
| File | Purpose |
|------|---------|
| `README.md` | Project overview and setup |
| `docs/FIGMA_WIREFRAME_BRIEF.md` | UI specifications |
| `docs/PROCESS.md` | Process documentation |
| `docs/DEVELOPMENT_METHODOLOGY.md` | This file |
| `CLAUDE.md` | AI assistant instructions |

### Plan Files
Sprint plans are stored in `.claude/plans/` with:
- Implementation steps
- Acceptance criteria mapping
- Files to modify
- Testing checklist

---

## 7. Testing Strategy

### Manual Testing
- Test each feature after implementation
- Verify acceptance criteria are met
- Test on iOS Simulator

### Automated Analysis
- Run `dart analyze` before committing
- Fix all errors, evaluate warnings
- Use `dart format` for consistent styling

### Testing Checklist
Before closing a PR:
- [ ] Feature works as expected
- [ ] No analyzer errors
- [ ] Settings/data persist correctly
- [ ] UI matches wireframe specs
- [ ] Edge cases handled (empty states, errors)

---

## 8. Issue Closing

### When to Close
Close issues when:
- All acceptance criteria are met
- Code is merged to main
- Feature is verified working

### How to Close
```bash
gh issue close #XX --comment "Implemented in PR #YY"
```

Or include `Closes #XX` in PR description for automatic closing.

---

## Tools Used

| Tool | Purpose |
|------|---------|
| GitHub Issues | Task tracking |
| GitHub PRs | Code review |
| Gemini Code Assist | Automated review |
| Flutter/Dart | Development |
| iOS Simulator | Testing |
| Claude Code | AI pair programming |

---

## Quick Reference

### Starting a New Feature
```bash
git checkout main && git pull
git checkout -b feature/my-feature
# ... develop ...
git add . && git commit -m "feat: description"
git push -u origin feature/my-feature
gh pr create
```

### Evaluating Review Comments
1. Read the suggestion carefully
2. Ask: Is this a bug fix? → IMPLEMENT
3. Ask: Is this critical for this phase? → IMPLEMENT or DEFER
4. Ask: Is this just style preference? → DISCARD

### Closing a Sprint
1. Merge all PRs
2. Close all issues with PR references
3. Pull main locally
4. Plan next sprint
