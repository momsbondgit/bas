- use implementation.md to excute the task below: 

---

# **AI Agent Task: Deploy Web Build to GitHub Pages**

## Steps

1. **Clean Old Build**

   * Remove all files and signs of the previous web build in the `main` branch.

2. **Build for Web (No Service Worker)**

   * Run Flutter build with service worker disabled:

     ```bash
     flutter build web --pwa-strategy=none --base-href /
     ```
   * **Why:**

     * Disables service worker so browsers always fetch the latest files.
     * Ensures correct base href for custom domain **[www.bas.today](http://www.bas.today)**.

3. **Custom Domain Setup**

   * Add `CNAME` file with:

     ```
     www.bas.today
     ```
   * Make sure this file is inside the build directory.

4. **Deploy to harsh2 Branch**

   * Checkout the `harsh2` branch.
   * Delete all old web build files from that branch. (except .git)
   * Copy **only the contents of the new `build/web` folder** into the root of the branch.
   * Commit and push changes.

   Example commands:

   ```bash
   git checkout harsh2
   rm -rf *
   cp -r ../build/web/* .
   git add .
   git commit -m "Deploy new web build"
   git push origin harsh2
   ```

5. **GitHub Pages Hosting**

   * Remote is already set up to serve from the `harsh2` branch root.
   * Once pushed, deployment should update automatically.

---

## Goal

* Fresh, clean deployment with no leftovers.
* Correct domain setup (`www.bas.today`).
* Build served from the **root of harsh2 branch** for GitHub Pages.

---