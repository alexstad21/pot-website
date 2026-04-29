# Proof of Travel — Web Site

Marketing and documentation site for [proofoftravel.io](https://proofoftravel.io).

Static HTML/CSS/JS, designed to be deployed to **Azure Static Web Apps** with GitHub Actions push-to-deploy.

---

## Project layout

```
Proof Of Travel Web Site/
├── src/                              # Site root (this is what gets deployed)
│   ├── index.html                    # Home page
│   ├── protocol.html                 # How the protocol works
│   ├── consolidators.html            # Integration story for consolidators
│   ├── whitepapers.html              # Whitepaper / docs index
│   ├── case-study.html               # Airspace disruption case study
│   ├── qa.html                       # FAQ / Q&A
│   ├── privacy.html                  # Privacy & compliance
│   ├── 404.html                      # Custom 404
│   ├── robots.txt
│   ├── sitemap.xml
│   ├── staticwebapp.config.json      # Azure SWA config (routing, headers, MIME)
│   └── assets/
│       ├── css/styles.css            # Shared stylesheet for all pages
│       ├── js/main.js                # Tiny site-wide JS (logo fallback)
│       └── img/favicon.svg
├── .github/
│   └── workflows/
│       └── azure-static-web-apps.yml # CI/CD to Azure SWA
├── .gitignore
├── proofoftravel-homepage.html       # Original single-file homepage (kept for reference)
└── README.md
```

The site is intentionally framework-free — pure HTML/CSS/JS — so it loads fast, hosts cheaply, and is easy to maintain.

---

## Local preview

Anything that serves the `src` folder over HTTP works. A few options:

**.NET CLI:**
```powershell
dotnet tool install -g dotnet-serve
cd src
dotnet serve -p 8080
```

**Node:**
```powershell
npx http-server src -p 8080 -c-1
```

**VS Code:**
Install the *Live Server* extension, right-click `src/index.html`, *Open with Live Server*.

Then browse to <http://localhost:8080>.

> Open files via the local server, not via `file://` — `staticwebapp.config.json` and absolute paths (`/assets/...`) need a proper HTTP origin.

---

## Deploy to Azure Static Web Apps

### 1. Create the Azure resource

In the Azure Portal:

1. **Create resource → Static Web App**.
2. **Plan**: *Free* is fine for this site.
3. **Region**: pick the one closest to your audience.
4. **Deployment source**: *GitHub*. Authorise and pick the repo + `main` branch.
5. **Build details**:
   - *Build presets*: **Custom**
   - *App location*: `src`
   - *Api location*: *(leave empty)*
   - *Output location*: *(leave empty)*
6. Create. Azure will commit a workflow file to your repo automatically — that's fine; the one in this repo is functionally equivalent and will be used on the next push.

### 2. Wire up the deployment token

Azure auto-creates a secret named `AZURE_STATIC_WEB_APPS_API_TOKEN` in the GitHub repo. The workflow in `.github/workflows/azure-static-web-apps.yml` consumes it. Nothing further needed.

If the secret is named differently (Azure sometimes generates a random suffix), either rename it in *Settings → Secrets and variables → Actions*, or update the `secrets.AZURE_STATIC_WEB_APPS_API_TOKEN` reference in the workflow.

### 3. Custom domain (proofoftravel.io)

In the SWA resource:

1. **Custom domains → Add → Custom domain on other DNS**.
2. Add `proofoftravel.io` (apex) and `www.proofoftravel.io`.
3. Azure gives you a TXT record (validation) and a CNAME / ALIAS / A target. At your DNS provider:
   - For the **apex** domain (`proofoftravel.io`) — use ALIAS / ANAME if your DNS host supports it, pointing to the SWA hostname; otherwise create the validation TXT first, then use Azure's CNAME-flattening / "apex domain" flow.
   - For **www** — CNAME to the SWA hostname Azure provides.
4. Free SSL certificates are issued automatically once DNS validates.

### 4. Push and ship

```powershell
git init
git add .
git commit -m "Initial site"
git branch -M main
git remote add origin https://github.com/<your-user>/<repo>.git
git push -u origin main
```

GitHub Actions runs `azure-static-web-apps.yml`, uploads `src/`, and the site is live at the SWA URL within ~1–2 minutes. Pull requests get automatic preview environments.

---

## Editing the site

- **Shared layout** (nav, footer, CSS) lives in `src/assets/css/styles.css`. Each HTML page includes the same `<nav>` and `<footer>` markup — keep them consistent.
- **New pages**: copy `protocol.html` as a template, update `<title>`, the `<header class="page-header">`, and the inner sections. Add the page to `sitemap.xml` and to the nav links on every page.
- **Routing**: `staticwebapp.config.json` handles 404 fallbacks, security headers, and any redirects you want to add.
- **Forms / dynamic features**: SWA supports a managed Functions API. If/when you need that, add an `api/` folder and set `api_location: "api"` in the workflow.

---

## Notes

- The site uses Google Fonts (Syne + DM Sans). The `Content-Security-Policy` header in `staticwebapp.config.json` allows them — adjust if you self-host fonts.
- The original single-file homepage is preserved as `proofoftravel-homepage.html` for reference and is **not** deployed (it sits outside the `src` folder).
- The favicon at `src/assets/img/favicon.svg` is a placeholder — drop in your real one anytime.
