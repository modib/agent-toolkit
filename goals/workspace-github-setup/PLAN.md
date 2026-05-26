# Goal: Workspace + GitHub Workflow Setup

## Desired Outcome
- ~/Workspace is the default workspace for all projects
- All projects live under ~/Workspace and are git repos
- Personal projects are on GitHub under the modib account
- A meta-project tracks goose configuration and skills

## Assumptions
- GitHub username is "modib" (from existing repo remotes)
- SSH key is already set up for GitHub (repos pull without password)
- The 3 fork repos (mbp2018-etc, mbpfan, T2-*) are upstream clones, not personal forks needing pushes

## Architecture
A hybrid structure:
1. **Personal projects** (bobby-theme, browser-ninja) — already on GitHub, clean
2. **Upstream forks** (mbp2018-etc, mbpfan, T2-Debian-and-Ubuntu-Kernel, T2-Ubuntu) — track upstream, no push needed
3. **velocity.dev** — empty, needs initializing as personal project
4. **goose-config** — new meta-repo at `~/Workspace/goose-config` for ~/.agents/skills/ and config docs
5. **Default workspace** — set goose working dir to ~/Workspace

## Phases

### Phase 1: Initialize & Set Default Workspace
**Goal:** Set goose to use ~/Workspace, init repos for projects without git
**Key Deliverables:**
- [ ] Update goose config to use ~/Workspace
- [ ] Init git repo for velocity.dev
- [ ] Create goose-config meta-repo for skills and config
- [ ] Init git repo for ~/.agents/ tracked via goose-config

### Phase 2: Create GitHub Repos & Push
**Goal:** Push personal projects to GitHub
**Key Deliverables:**
- [ ] Create velocity.dev repo on GitHub
- [ ] Create goose-config repo on GitHub
- [ ] Push all repos

### Phase 3: Verify
**Goal:** Confirm everything is working
**Key Deliverables:**
- [ ] Verify git status of all repos — all clean
- [ ] Verify remotes are correct
- [ ] Verify goose sessions default to ~/Workspace