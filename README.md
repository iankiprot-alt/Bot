# IanMegaBot — WhatsApp Bot (Baileys)

A small WhatsApp bot built with @adiwajshing/baileys. This repo includes a ready-to-run project (index.js, package.json, start.sh) plus artifacts for deployment (Procfile, Dockerfile). This README explains how to run the bot locally, how to reuse authentication for headless runs (useful when running the bot on a phone or a server), and common troubleshooting.

Important notes
- index.js uses ES modules. Ensure `package.json` includes:
```json
{
  "type": "module"
}
```
- Node.js 18+ is required.
- You cannot scan the QR with the same phone the bot runs on. Either run the bot on a separate machine (desktop/VPS) and scan from your phone, or create an auth bundle from a device that scanned the QR and import it into the target device (phone/Termux/Docker) using AUTH_TAR_B64.

Requirements
- Node.js >= 18
- npm (or yarn)
- zip (if using the generator script)
- For running on Android: Termux with nodejs (or a Linux environment on the phone)

Quick start (desktop / normal environment)
1. Clone repo and enter folder:
```bash
git clone https://github.com/iankiprot-alt/Ianohmegabot.git
cd Ianohmegabot
```

2. Ensure `start.sh` is executable:
```bash
chmod +x start.sh
```

3. Install dependencies:
```bash
npm ci
# or
npm install
```

4. Start the bot:
```bash
npm start
```
- On first run a QR will be printed in the terminal (because no ./auth state exists). Scan it from your phone WhatsApp to link the bot. After scanning, the `./auth` folder will be created.

Creating an auth bundle to reuse on another device (recommended if running on phone/Termux)
1. After scanning the QR on a machine and `./auth` is created, stop the bot and create a tar.gz:
```bash
tar -czf auth.tar.gz auth
```

2. Base64-encode into a single-line env value (choose the right command for your platform):

- Linux (GNU base64):
```bash
base64 -w0 auth.tar.gz > auth.b64
```

- macOS (BSD base64):
```bash
base64 auth.tar.gz | tr -d '\n' > auth.b64
```

- Termux / Busybox (if base64 supports -w):
```bash
base64 -w0 auth.tar.gz > auth.b64
# or if -w not supported:
base64 auth.tar.gz | tr -d '\n' > auth.b64
```

3. The file auth.b64 contains the single-line string to use as AUTH_TAR_B64. You can export it in the shell:
```bash
export AUTH_TAR_B64="$(cat auth.b64)"
npm start
```

Or pass it inline:
```bash
AUTH_TAR_B64="$(cat auth.b64)" npm start
```

How the bot consumes AUTH_TAR_B64
- `start.sh` checks the `AUTH_TAR_B64` environment variable, decodes it, extracts it to `./auth`, then runs `node index.js`. This allows headless startup without interactive QR scanning.

Running the bot on a phone (Termux) — recommended approach
- Best approach: create auth bundle on a desktop, transfer the base64 string or auth.tar.gz to the phone, then run with AUTH_TAR_B64 (or extract the auth folder directly into Termux).

Termux example (after transferring auth.tar.gz to phone):
```bash
# in Termux
pkg update && pkg install nodejs git tar
cd ~/storage/shared/your-folder
# copy auth.tar.gz here or move it
tar -xzf auth.tar.gz -C ./auth
chmod +x start.sh
npm ci
npm start
```

Or using AUTH_TAR_B64:
```bash
# put auth.b64 on phone, then:
export AUTH_TAR_B64="$(cat auth.b64)"
npm start
```

Docker (local)
- Build:
```bash
docker build -t ianohmegabot .
```
- Run with local auth volume (recommended):
```bash
docker run -v "$(pwd)/auth:/app/auth" -it ianohmegabot
```
- Or pass AUTH_TAR_B64 env var:
```bash
docker run -e AUTH_TAR_B64="$(cat auth.b64)" -it ianohmegabot
```

Deploying to platforms (Railway, Heroku, etc.)
- Set an environment variable `AUTH_TAR_B64` in the platform's Secrets/Environment configuration with the contents of auth.b64.
- Start command: `npm start` (Procfile includes `web: npm start`).

Common commands and examples
- Make start executable:
```bash
chmod +x start.sh
```
- Install deps:
```bash
npm ci
```
- Start:
```bash
npm start
```

Troubleshooting
- "SyntaxError: Cannot use import statement outside a module"
  - Add `"type": "module"` to package.json.
- QR not shown or unreadable
  - Run the bot on a machine you can view comfortably (desktop terminal). The phone that will link must scan the QR from another device's terminal.
- Auth problems after extraction
  - Ensure auth folder was created by a successful Baileys session; mismatched versions may break compatibility.
- Missing modules
  - Run `npm ci` / `npm install` and ensure network access.
- Permissions
  - Ensure `start.sh` is executable and node has permission to write to `./auth` and `./media` directories.

Security / privacy
- The `auth` folder contains credentials that allow a linked WhatsApp account to be used by the bot. Protect `auth.tar.gz` and `auth.b64` and don't commit them to git. `.gitignore` already excludes `auth/*` and `media/*`.
- Treat `AUTH_TAR_B64` as a secret when deploying; use your host's secret storage.

Files of interest
- `index.js` — bot logic (Baileys)
- `package.json` — ensure `"type": "module"` present
- `start.sh` — decodes AUTH_TAR_B64 and ensures media directories
- `Dockerfile`, `Procfile` — deployment helpers

License
- MIT

If you want, I can:
- Add a short section with exact Termux installation steps tailored to your phone (Android model / Termux version).
- Create a one-line patch to update `create_full_project_zip.sh` so it writes the corrected `start.sh` and `package.json` automatically.
Which would you like next?
```
