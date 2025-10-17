# NIP-05 Verification

This repo hosts the tiny JSON file that powers **NIP-05** verification for my Nostr handle:

```
omg@biscuits.lol
```

NIP-05 lets Nostr clients verify that a human-readable handle (`name@domain`) maps to a specific **hex** public key. Clients fetch:

```
https://<domain>/.well-known/nostr.json?name=<name>
```

…and check the returned mapping.

## What this repo contains

```
/
├── .nojekyll
└── .well-known/
    └── nostr.json
```

- `/.well-known/nostr.json` — the NIP-05 mapping. ⚠️ The value must be the **hex** pubkey (64 hex chars), **not** the `npub…` string.
- `.nojekyll` — required on GitHub Pages so `/.well-known/` is served verbatim (no Jekyll processing).

## Quick start: GitHub Pages + custom domain (no Azure)

This is the simplest setup. Serve the file directly from GitHub Pages under your own domain.


### 1) Enable GitHub Pages

In your repo:

1. **Settings → Pages**
2. **Source:** “Deploy from a branch”  
   **Branch:** `main`  
   **Folder:** `/ (root)`
3. Save.

A public `https://<username>.github.io/<repo>/` URL will appear when the deploy finishes.

### 2) Attach your custom domain

Still on **Settings → Pages**:

1. In **Custom domain**, enter your domain (e.g., `biscuits.lol` or a subdomain like `id.biscuits.lol`. I personally prefer the root domain as I think it looks cleaner).
2. Save, then tick **Enforce HTTPS** once the certificate is issued.

### 3) Point DNS (at your registrar)

At your DNS provider:

- **If using the apex/root (`biscuits.lol`)**  
  Use an **ALIAS/ANAME** (or the four A/AAAA records GitHub lists). Example with ALIAS:
  - Type: `ALIAS`  
  - Host: `@` (or blank for root)  
  - Value: `<username>.github.io`  
  - TTL: 600–3600

- **If using a subdomain (`id.biscuits.lol`)**  
  Use **CNAME**:
  - Type: `CNAME`  
  - Host: `id`  
  - Value: `<username>.github.io`  
  - TTL: 600–3600

> If your apex also handles email, **prefer ALIAS** at the apex so MX/TXT records can coexist.

### 4) Verify it works

After DNS and the Pages cert are live:

```bash
curl -s https://biscuits.lol/.well-known/nostr.json?name=omg | jq .
```

You should see the JSON with the hex key. Now set your Nostr profile’s NIP-05 field to:

```
omg@biscuits.lol
```

Your client should show a verified check/indicator.

## Optional: Azure Front Door in front of GitHub Pages

You **do not** need Azure for this. However, if you want your domain to do more than serve static files (e.g., route some paths to a function, add headers, or split traffic, whatever), and especially if you are using the root domain, you can place **Azure Front Door** in front. It doesn’t have to be Azure Front Door of course, anything that handles custom routing (eg Nginx):

**High-level steps**

1. You still need Step 1 from the GitHub Pages Section, Azure Front Door will point to this Url.
1. Create a Front Door profile (Standard is fine).  
2. **Origin** = `yourusername.github.io`, **Origin path** = `/<this-repo-name>` (since this is a project site).  
3. **Route** `/*` → that origin (HTTPS).  
4. Add your custom domain (e.g., `biscuits.lol`), validate via TXT, enable managed TLS.  
5. At your registrar, set apex **ALIAS** → `<endpoint>.z01.azurefd.net`.  
6. (Later) Add a second origin (e.g., Azure Function) and a higher-priority route for any dynamic paths you need.

> With Front Door, GitHub Pages does **not** need to know your custom domain; Front Door terminates TLS and fetches from the default Pages origin.

## Multi-user / directory style (optional)

If you plan to host mappings for multiple friends under your domain, extend `nostr.json`:

```json
{
  “names”: {
    “omg”:   “BLAHHEXBLAHBLAH”,
    “alice”: “HEXHEXBLAHBLAHBLAH”,
    “bob”:   “BLAHBLAHBLAHHEXHEXBLAH”
  }
}
```

Then they can set `alice@biscuits.lol`, `bob@biscuits.lol`, etc., in their clients. (If you want governance/auditability, accept PRs to change entries and protect `main`.)

I’ve had a think about this. I think it’s an interesting way of building a web of trust. People you meet in real life, you can offer to publicly validate them on your domain. But current NIP-05 implementation (as I understand it) doesn’t take into account multiple verifications for one user, which seems to me to be the natural extension of this idea. Maybe this would be the subject of a different NIP in the future…

## Security & trust notes

- NIP-05 inherits trust from your **domain control**. The green check (or whatever colour it might be) means “the domain asserts this mapping,” not real-world identity proof. Keep the repo secure and limit who can modify `nostr.json`.
- Treat the repo as an **attestation**: changes are meaningful; use reviews for updates.
- If you later move hosting (e.g., different static host or Azure Front Door), keep serving the **same file at the same path** and you’re fine.
 