# ghewareunigps.com

Company website of **GHEWARE UNIGPS SOLUTIONS LLP** (Bengaluru), served by GitHub Pages at https://ghewareunigps.com.
Spec: issue #1.

Plain static HTML and CSS: no build step, no framework, no JavaScript.

| File | What |
|---|---|
| `index.html` | The page, including the `<title>`, meta description, Open Graph tags and the `Organization` JSON-LD block |
| `404.html` | Shown by GitHub Pages for any unknown path |
| `assets/style.css` | All styling; light and dark colours are CSS variables at the top (`prefers-color-scheme`) |
| `assets/favicon.svg`, `favicon.ico`, `assets/apple-touch-icon.png` | Icons |
| `assets/og-image.png` | 1200×630 link-preview image |
| `CNAME` | Custom domain for GitHub Pages (`ghewareunigps.com`); don't delete it |
| `scripts/make-images.py` | Regenerates the PNG/ICO images (needs Pillow) |
| `scripts/cloudflare-dns.sh` | One-off DNS change that points the domain at GitHub Pages |
| `docs/` | Screenshots and checks from the first build |

## Editing

Edit `index.html` on GitHub (pencil icon) or locally, then commit to `main`. Pages republishes in about a minute.

- Company facts (legal name, GSTIN, address) must match the GST registration certificate exactly. They appear in
  three places in `index.html`: the visible "Company details" list, the footer, and the JSON-LD block. Change all three.
- The footer year is plain text (`© 2026`); update it each January.
- If you change the businesses or the tagline in the OG image, edit `scripts/make-images.py` and run
  `python3 scripts/make-images.py`.

Preview locally:

```bash
python3 -m http.server 8000     # then open http://localhost:8000
```

Before pushing, check the page at 390 px wide and on desktop, in light and dark, and that every external link
answers 200:

```bash
for u in $(grep -ohE 'https://[^"<> ]+' index.html | grep -vE 'ghewareunigps.com|schema.org' | sort -u); do
  echo "$(curl -s -o /dev/null -L -w '%{http_code}' "$u") $u"; done
```

## Deployment

GitHub Pages, branch `main`, folder `/` (root). Every push to `main` publishes. The `CNAME` file sets the custom domain.

One-time setup (owner):

1. Make the repo public (Pages on a free organisation needs it):
   `gh repo edit brainupgrade-in/ghewareunigpscom --visibility public --accept-visibility-change-consequences`
2. Enable Pages: Settings → Pages → Deploy from a branch → `main` / `/ (root)`, custom domain `ghewareunigps.com`.
3. Run `scripts/cloudflare-dns.sh`. It replaces the apex A record with GitHub's four Pages IPs and points `www` at
   `brainupgrade-in.github.io`, all DNS only (not proxied, so GitHub can issue the certificate). MX and TXT records
   (Google Workspace mail) are not touched. It is safe to run twice.
4. When Settings → Pages shows the certificate is issued, tick **Enforce HTTPS**. `www` then redirects to the apex.
