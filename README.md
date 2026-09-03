# safeerkhan.com

A plain HTML/CSS/JS photography portfolio. No build step, no framework, no
dependencies — it works by opening `index.html` directly or serving the
folder as-is.

## Preview locally

Any static file server works. From the project root:

```
python3 -m http.server 8000
```

Then open `http://localhost:8000`. (Opening `index.html` directly by
double-clicking it also works, since there's no build step and no fetch
calls — everything is a relative file reference.)

## Adding a photo

1. **Resize it.** Put your full-resolution export in any source folder
   (outside the repo, or in a local `originals/` folder — both are
   gitignored) and run:

   ```
   tools/resize.sh /path/to/source-folder
   ```

   This writes a web-ready copy into `images/gallery/`: long edge scaled to
   2000px, JPEG quality 80, filename lowercased with spaces replaced by
   hyphens. It requires ImageMagick (`brew install imagemagick`) and never
   modifies your source files.

2. **Get its pixel dimensions**, needed for the `width`/`height` attributes:

   ```
   sips -g pixelWidth -g pixelHeight images/gallery/your-photo.jpg
   ```

3. **Add one block to `index.html`.** Copy an existing `<a class="photo">`
   entry in the gallery section and update:

   - `href` and `src` → `images/gallery/your-photo.jpg`
   - `width` / `height` → the real dimensions from step 2 (this is what
     avoids layout shift while the image loads)
   - `alt` → override the filename-derived text if it needs a hand edit
     (there's a comment marking where to do this)

   Feel free to delete the placeholder blocks as you replace them.

4. **Preview locally** (see above) to check placement and the lightbox.

5. **Commit and push:**

   ```
   git add images/gallery/your-photo.jpg index.html
   git commit -m "Add your-photo"
   git push
   ```

That's the whole loop — no manifest file, no build script, no GitHub
Action to maintain.

## Enabling GitHub Pages

1. Push this repo to GitHub (repo name doesn't matter for a custom domain).
2. In the repo, go to **Settings → Pages**.
3. Under **Build and deployment**, set **Source** to `Deploy from a branch`,
   branch `main`, folder `/ (root)`.
4. Under **Custom domain**, enter `safeerkhan.com` and save. (The `CNAME`
   file already in this repo does the same thing — GitHub will keep it in
   sync with whatever you enter here.)
5. Once DNS (below) is in place and verified, check **Enforce HTTPS**.

## DNS records for the custom domain

At your domain registrar, point `safeerkhan.com` at GitHub Pages with four
`A` records (apex domain) and one `CNAME` record (`www` subdomain):

| Type  | Host/Name | Value               |
|-------|-----------|---------------------|
| A     | @         | 185.199.108.153     |
| A     | @         | 185.199.109.153     |
| A     | @         | 185.199.110.153     |
| A     | @         | 185.199.111.153     |
| CNAME | www       | safkha.github.io.   |

Replace `safkha.github.io.` with your actual `<username>.github.io.` if
different — check the repo's GitHub Pages settings page, which shows the
exact value once Pages is enabled. DNS changes can take anywhere from a
few minutes to 24 hours to propagate.

## If you split galleries by category later

Right now everything lives in one continuous grid on `index.html`. If you
later want separate pages per category (e.g. `street.html`,
`landscape.html`):

- Add a shared nav in the header linking between pages, and duplicate the
  header/footer markup across each page (still no templating — just copy
  the HTML).
- Split the existing `<a class="photo">` blocks into the relevant page
  based on subject.
- `script.js` and `style.css` don't need any changes — the lightbox and
  grid logic operate on whatever `.photo` elements exist on the current
  page, so they work unmodified on each new page.
- `index.html` would become a landing/intro page, or just become the
  first category — your call.

This keeps every page statically crawlable (good for SEO) without adding
a build step or a JS router.
