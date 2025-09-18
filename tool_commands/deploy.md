

---

### Task for AI Agent: Fix Flutter Web showing old build on GitHub Pages (gh-pages branch empty)

**Problem (1-sentence):**
Deployed site sometimes shows an **old build** because a previously cached Flutter **service worker** serves stale assets.

**Goal:**
Deploy a fresh **non-PWA** release build to the empty `gh-pages` branch so browsers fetch the latest files (no cached SW).

**MANDATORY WORKFLOW:**
At every step, **pause and ask me to confirm** before proceeding. Do not continue without my explicit “OK.”

**Steps to implement (use exactly these commands):**

1. **Prepare a clean release build with SW disabled**

```bash
flutter clean
rm -rf build/
flutter pub get
# If your site is at https://username.github.io/<repo> use the /<repo>/ base-href
flutter build web --release --pwa-strategy=none --web-renderer html --base-href /<repo>/
```

2. **Deploy to the empty gh-pages branch using worktree (cleanest & safe)**

```bash
# from repo root on main branch
git fetch origin
git worktree add gh-pages gh-pages   # creates a gh-pages/ folder checked out to the gh-pages branch
rsync -av --delete build/web/ gh-pages/   # mirror fresh build into deploy dir
touch gh-pages/.nojekyll
cd gh-pages
git add -A
git commit -m "Deploy fresh web build (no PWA) $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
git push origin gh-pages
cd ..
```

3. **GitHub Pages settings**

* Ensure **Pages → Source** is set to **Branch: `gh-pages` / Root**.
* If using a **custom domain**, add a `CNAME` file in `gh-pages/` with the domain and rebuild with `--base-href /`.

4. **Verify (freshness check)**

* Open the site in **Incognito**.
* Confirm:

  * There is **no** `flutter_service_worker.js` in the deployed branch.
  * First load requests return **200** (not “from cache”).
  * The UI shows the latest changes. (Add a tiny build stamp in UI if needed.)

**Acceptance criteria:**

* Page loads latest code on first visit (no hard refresh needed).
* No service worker registered (DevTools → Application → Service Workers shows none).
* `gh-pages` contains only the contents of `build/web/` plus `.nojekyll` (and `CNAME` if used).

**Ongoing deploys (until we want PWA):**
Repeat Steps 1–2 for each release. Keep `--pwa-strategy=none`. Always `rsync --delete` to avoid stale files.

