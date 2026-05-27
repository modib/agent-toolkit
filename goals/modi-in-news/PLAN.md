# Goal: modi.in — Indian Political News Credibility Tracker

## Desired Outcome
A local website `modi.in` that:
1. Daily researches Indian political news
2. Identifies viral/most-viewed articles
3. Rates each article for credibility (information, author, website)
4. Shows card view with ratings
5. Popup details when clicking cards
6. Creates audio summary
7. Ensures data is <24 hours old for global audience

## Status: ✅ COMPLETE — Delivered May 26, 2026

## Architecture (Actual)

**Tech Stack (pivoted from original plan):**
- **Backend:** Node.js + Express
- **Frontend:** Vanilla HTML/CSS/JS (no framework needed)
- **Data Storage:** JSON file-based (no database required for 8 articles/cycle)
- **News Sources:** Google News RSS
- **AI Audio:** Google Translate TTS (NotebookLM blocked by login — documented manual workflow)
- **AI Evaluation:** Gemini 2.5 Flash + heuristic fallback

**Why Node.js over Python/React?**
- Simpler deployment (no venv, no build step)
- Puppeteer needed for NotebookLM automation
- Vanilla JS frontend is faster-loading and zero-dependency

## What Was Delivered

### ✅ Phase 1: Foundation
- Express server on port 3000
- `/etc/hosts` entry for `modi.im`
- Dark-themed responsive UI

### ✅ Phase 2: News Pipeline
- Google News RSS fetches 100 articles, takes top 8
- Cron: `0 */12 * * *` (8AM/8PM IST)
- Deduplication via title parsing

### ✅ Phase 3: Credibility Rating
- 12 curated sources with trust scores (PTI 95, The Hindu 92, etc.)
- 5-dimension matrix: factuality(35%), neutrality(15%), sourceTrust(20%), citations(15%), authorIntegrity(15%)
- A-F grading with color coding
- Gemini AI eval → heuristic fallback
- Clickbait/ALL-CAPS detection

### ✅ Phase 4: Card UI + Popups
- Responsive card grid with grade badges
- Animated score bars on click
- Chrome Gemini Nano integration
- Search, grade filter, sort controls

### ✅ Phase 5: Audio Summary
- Text-to-speech via Google Translate API
- Custom audio player (play/pause/seek/volume)
- 7-day audio archive with auto-rotation
- NotebookLM manual workflow documented

### ✅ Phase 6: Polish
- Comprehensive README
- `.env.example` + `.gitignore`
- Error handling with graceful fallbacks

## Deviations from Plan
- **Tech stack:** Node.js/vanilla JS instead of Python/FastAPI/React — simpler, faster, no build step
- **Database:** JSON files instead of SQLite — sufficient for 8 articles/cycle
- **Audio:** Google Translate TTS instead of Gemini TTS — Gemini TTS not available as standalone API; NotebookLM requires manual login
- **Filter/sort:** Added beyond original scope

## Files
- `~/Workspace/modi.in/` — Live project
- Cron runs at `0 */12 * * *`
- Access at `http://modi.in:3000`