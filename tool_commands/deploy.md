- use implementation.md to excute the task below: 

---

# **AI Agent Task: Deploy Web Build to GitHub Pages**

## Steps

1. **Clean Old Build**

   * Remove all files and signs of the previous web build in the `current` branch.

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

4. **Deploy to deployment Branch**

   * Checkout the `deployment` branch.
   * Delete everything related to the old build. 
   * Copy **only the contents of the new `build/web` folder** into the root of the deployment  branch from the previous branch.
   * Commit and push changes.

   Example commands:

   ```bash
   git checkout deployment
   rm -rf *
   cp -r ../build/web/* .
   git add .
   git commit -m "Deploy new web build"
   git push origin deployment
   ```

5. **GitHub Pages Hosting**

   * Remote is already set up to serve from the `deployment` branch root.
   * Once pushed, deployment should update automatically.

---

## Goal

* Fresh, clean deployment with no leftovers.
* Correct domain setup (`www.bas.today`).
* Build served from the **root of deployment branch** for GitHub Pages.

---