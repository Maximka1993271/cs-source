<h1 align="center">SoundForge Equalizer v3.22.8</h1>

<p align="center">
  <a href="https://github.com/Maximka1993271/SoundForge-Equalizer/releases">
    <img src="https://img.shields.io/badge/version-3.22.8-blue.svg?style=for-the-badge&logo=github" alt="Version"/>
  </a>
  <a href="https://www.microsoft.com/edge">
    <img src="https://img.shields.io/badge/Edge-Chromium-0078D7.svg?style=for-the-badge&logo=microsoft-edge" alt="Edge"/>
  </a>
  <a href="https://www.mozilla.org/en-US/firefox/enterprise/">
    <img src="https://img.shields.io/badge/Firefox-ESR-FF7139.svg?style=for-the-badge&logo=firefox-browser" alt="Firefox"/>
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge" alt="License"/>
  </a>
  <a href="https://github.com/Maximka1993271/SoundForge-Equalizer/releases">
    <img src="https://img.shields.io/github/downloads/Maximka1993271/SoundForge-Equalizer/total.svg?style=for-the-badge&logo=github" alt="Downloads"/>
  </a>
  <a href="https://github.com/Maximka1993271/SoundForge-Equalizer">
    <img src="https://img.shields.io/badge/Open%20Source-✅-brightgreen.svg?style=for-the-badge" alt="Open Source"/>
  </a>
  <a href="https://github.com/Maximka1993271/SoundForge-Equalizer">
    <img src="https://img.shields.io/badge/Last%20Commit-2026--07--31-blue.svg?style=for-the-badge&logo=github" alt="Last Commit"/>
  </a>
  <a href="https://github.com/Maximka1993271/SoundForge-Equalizer">
    <img src="https://img.shields.io/badge/Code%20Style-ES2020-yellow.svg?style=for-the-badge&logo=javascript" alt="Code Style"/>
  </a>
  <a href="https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API">
    <img src="https://img.shields.io/badge/Web%20Audio%20API-Supported-orange.svg?style=for-the-badge&logo=web-audio" alt="Web Audio API"/>
  </a>
  <a href="https://github.com/Maximka1993271/SoundForge-Equalizer">
    <img src="https://img.shields.io/badge/Cross--Browser-Chrome%20%7C%20Firefox%20%7C%20Edge-blueviolet.svg?style=for-the-badge" alt="Cross-Browser"/>
  </a>
  <a href="https://github.com/Maximka1993271/SoundForge-Equalizer">
    <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge&logo=github" alt="PRs Welcome"/>
  </a>
</p>

<p align="center">
  <img src="https://github.com/Maximka1993271/SoundForge-Equalizer/raw/main/Screenshots/Full%20Equalizer.png" alt="SoundForge Equalizer" width="600"/>
</p>

<p align="center">
  <b>🎛️ Professional 10-Band Browser Equalizer</b><br/>
  Professional real-time audio processing for YouTube and other supported websites.<br/>
  <b>🔓 Free • Open Source • Privacy First • Cross-Browser</b>
</p>

---

## ⚠️ Official Source Warning

> **🚨 IMPORTANT: This is the ONLY official distribution channel for SoundForge Equalizer.**
>
> This extension is **only published on GitHub** under this repository:
> **[https://github.com/Maximka1993271/SoundForge-Equalizer](https://github.com/Maximka1993271/SoundForge-Equalizer)**
>
> **I DO NOT upload this extension to:**
> - ❌ Chrome Web Store
> - ❌ Firefox Add-ons Store (AMO)
> - ❌ Microsoft Edge Add-ons Store
> - ❌ Telegram
> - ❌ Any other websites, file hosting services, or social media platforms
>
> **If you find this extension anywhere else, it is NOT the original version and may contain malware, spyware, or modified code.**
>
> **Always download from the official GitHub repository only!**

---

## ⭐ Project Highlights

- ✅ **Free & Open Source** — MIT License
- ✅ **Microsoft Edge, Google Chrome and Mozilla Firefox**
- ✅ **10-Band Equalizer** — 31Hz – 16kHz, 0.5 dB steps, ±12 dB
- ✅ **50 Built-in Presets** — For all music genres
- ✅ **Real-Time Audio Processing** — Web Audio API
- ✅ **Spectrum Analyzer, VU Meter & Frequency Response Graph**
- ✅ **Volume Boost** — 0% – 800% with hard mute at 0%
- ✅ **Import / Export Presets** — JSON backup
- ✅ **Per-Site Settings** — Settings saved per domain
- ✅ **Keyboard Shortcuts** — 4 shortcuts for quick control
- ✅ **Dark / Light / System Themes** — Auto-sync with OS
- ✅ **Separate Window Mode** — Full equalizer in standalone window
- ✅ **No Ads • No Tracking • No Telemetry**
- ✅ **100% Local Audio Processing**
- ✅ **Night Mode** — Auto 22:00 – 07:00 with 30% volume reduction
- ✅ **Power Save Mode** — Reduces update frequency to save CPU
- ✅ **History & Statistics** — Tracks all changes (up to 1000 entries)
- ✅ **Clipping Detection** — Visual warning when audio clips
- ✅ **4 Visualization Effects** — Spectrum | Waves | Fire | Neon
- ✅ **3 Languages** — English, Русский, Українська
- ✅ **Modular Architecture** — ES Modules
- ✅ **Memory Management & Leak Prevention**

---

## 🐛 v3.22.8 Fixes

- Fixed loading of saved EQ, volume, bass and preset settings on a fresh page load.
- Fixed the `getInjectSettings` response so the actual loaded settings are delivered to `inject.js`.
- Fixed AutoConnect behavior after an explicit user disconnect; manual Connect remains available.
- Verified the live volume pipeline from 0% to 800% without double conversion.
- Verified MV3 Service Worker state restoration, messaging, storage synchronization and per-tab state handling.
- Existing functionality was preserved; only the confirmed bugs were fixed in the corresponding release build.

---

## 🔒 Privacy

All audio processing is performed locally using the Web Audio API.
No advertisements, tracking, telemetry, analytics or user data collection.
**Your privacy is 100% protected.**

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎚️ **10-Band EQ** | 31Hz – 16kHz, 0.5 dB steps, ±12 dB |
| 📊 **Visualization** | Spectrum, VU Meter, Frequency Response Graph with grid |
| 🎛️ **50+ Presets** | For all music genres with ideal gain staging |
| 🔊 **Volume 0–800%** | From silence to maximum boost with hard mute at 0% |
| 🎚️ **Bass Boost** | ±12 dB Low-shelf filter at 100Hz |
| 🎨 **Three Themes** | Light, Dark, System (auto-sync with OS) |
| 💾 **Export/Import** | Save your settings as JSON backup |
| 🔀 **A/B Comparison** | Compare sound between two presets |
| 🌐 **3 Languages** | Русский, Українська, English |
| 🌙 **Night Mode** | Auto-enabled 22:00–07:00, 30% volume reduction |
| ⚡ **Power Save Mode** | Reduces update frequency to save CPU |
| 📜 **History** | Tracks all changes with timestamps (up to 1000 entries) |
| 📊 **Statistics** | Usage stats, most used presets, daily activity |
| 🎯 **Clipping Detection** | Visual warning when audio clips or volume is critical |
| 💾 **Per-Site Settings** | Settings saved per domain, auto-applied |
| ⌨️ **Keyboard Shortcuts** | 4 shortcuts for quick control |
| 🪟 **Separate Window** | Full equalizer in standalone window |
| 🎨 **4 Effects** | Spectrum \| Waves \| Fire \| Neon |
| 📦 **Manifest V3/V2** | Chrome MV3 + Firefox MV2 |
| 🔓 **Open Source** | Fully open source code with MIT License |

---

## 🎨 Visualization Effects

SoundForge now features **4 visualization modes** that transform your spectrum display. Switch between them anytime with a single click!

| Effect | Description |
|--------|-------------|
| 📊 **Spectrum** | Classic real-time frequency analyzer with colored bars |
| 🌊 **Waves** | Smooth flowing audio waves with dynamic amplitude response |
| 🔥 **Fire** | Animated flame effect that pulses with the music's energy |
| 💜 **Neon** | Glowing neon bars with particle effects and vibrant colors |

### How to Use

- Click the **🎨 Effect** button in the extension popup or standalone window
- Cycle through all 4 effects with each click
- The selected effect is saved and persists across sessions

🎨 Effect → 📊 Spectrum → 🌊 Waves → 🔥 Fire → 💜 Neon → 🔄

---

## 📸 Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="https://github.com/Maximka1993271/SoundForge-Equalizer/raw/main/Screenshots/soundforge-full-interfac.png" alt="SoundForge Full Interface" width="400"/>
        <br/>
        <b>🌙 Full Interface</b>
      </td>
      <td align="center">
        <img src="https://github.com/Maximka1993271/SoundForge-Equalizer/raw/main/Screenshots/soundforge-light-ui.png" alt="SoundForge Light UI" width="400"/>
        <br/>
        <b>☀️ Light UI</b>
      </td>
    </tr>
    <tr>
      <td align="center">
        <img src="https://github.com/Maximka1993271/SoundForge-Equalizer/raw/main/Screenshots/Full%20Equalizer.png" alt="Full Equalizer" width="400"/>
        <br/>
        <b>🎛️ Full Equalizer</b>
      </td>
      <td align="center">
        <img src="https://github.com/Maximka1993271/SoundForge-Equalizer/raw/main/Screenshots/On%20Player.png" alt="On Player" width="400"/>
        <br/>
        <b>🎵 On Player</b>
      </td>
    </tr>
  </table>
</div>

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+U` | Activate extension (open popup) |
| `Ctrl+Shift+E` | Toggle equalizer ON/OFF |
| `Ctrl+Shift+Y` | Next preset |
| `Ctrl+Shift+X` | Reset all settings |
| `Esc` | Close window (in standalone mode) |

---

## 🎛️ Presets List (50+)

### 🎵 Main
- `flat` — Reference
- `natural` — Natural
- `universal` — Universal
- `balanced` — Balanced

### 🎶 Electronic
- `club` — Club
- `dance` — Dance
- `edm` — EDM
- `synthwave` — Synthwave
- `deephouse` — Deep House
- `festival` — Festival

### 🎸 Rock / Metal
- `rock` — Rock
- `metal` — Metal
- `hardrock` — Hard Rock
- `grunge` — Grunge

### 🎤 Vocal / Podcast
- `vocal` — Vocal
- `podcast` — Podcast
- `speech` — Speech
- `rap` — Rap

### 🎻 Acoustic / Classical
- `acoustic` — Acoustic
- `piano` — Piano
- `orchestra` — Orchestra
- `classical` — Classical
- `jazz` — Jazz

### 🎧 Special
- `headphones` — Headphones
- `car` — Car
- `night` — Night
- `bassboost` — Max Bass
- `hiphop` — Hip-Hop
- `soul` — Soul
- `blues` — Blues
- `reggae` — Reggae
- `chill` — Chill
- `lofi` — Lo-Fi
- `sunset` — Sunset
- `pop` — Pop
- `kpop` — K-Pop
- `world` — World
- `ambient` — Ambient
- `clarity` — Clarity

### 🌊 Wave / Phonk
- `wave` — Wave
- `phonk` — Phonk/Drift

### ⚡ MAX BOOST
- `logitech` — Logitech G321
- `maxboost` — MAX BOOST ⚡

### 🎮 Gaming / Movie
- `gaming` — Gaming
- `movie` — Movie
- `fps` — FPS

### 🌟 Premium
- `hifi` — Hi-Fi
- `studio` — Studio
- `premium` — Premium
- `master` — Master

---

## 📥 Download & Installation

### 📦 Direct Download Links

| Version | Download |
|---------|----------|
| 🟦 **Microsoft Edge / Chromium** | [⬇️ SoundForge-Equalizer-v3.22.8-Edge.zip](https://github.com/Maximka1993271/SoundForge-Equalizer/releases/download/v3.22.8/SoundForge-Equalizer-v3.22.8-Edge.zip) |
| 🦊 **Firefox ESR (ZIP)** | [⬇️ SoundForge-Equalizer-v3.22.8-Firefox.zip](https://github.com/Maximka1993271/SoundForge-Equalizer/releases/download/v3.22.8-firefox/SoundForge-Equalizer-v3.22.8-Firefox.zip) |
| 🦊 **Firefox ESR (XPI)** | [⬇️ soundforge_equalizer-3.22.8.xpi](https://github.com/Maximka1993271/SoundForge-Equalizer/releases/download/v3.22.8-firefox/soundforge_equalizer-3.22.8.xpi) |

---

## 🔧 Installation

### 🔹 Microsoft Edge (Chromium)

1. Download the archive: [**SoundForge-Equalizer-v3.22.8-Edge.zip**](https://github.com/Maximka1993271/SoundForge-Equalizer/releases/download/v3.22.8/SoundForge-Equalizer-v3.22.8-Edge.zip)
2. Extract to any folder
3. Open Edge → `edge://extensions/`
4. Enable **"Developer mode"**
5. Click **"Load unpacked"** → select the **Microsoft Edge** folder

---

### 🔹 Firefox ESR

> **⚠️ Important:** This extension is NOT signed by Mozilla, so Firefox may block installation. Follow these steps to install it.

#### Option 1 — Quick Install (XPI file)

1. Download [**soundforge_equalizer-3.22.8.xpi**](https://github.com/Maximka1993271/SoundForge-Equalizer/releases/download/v3.22.8-firefox/soundforge_equalizer-3.22.8.xpi)
2. **Drag and drop** the `.xpi` file into an open Firefox window
3. Click **"Add"**

> **If Firefox blocks the installation:** Skip to Option 3 below to disable signature verification.

---

#### Option 2 — Manual Install (ZIP file)

1. Download [**SoundForge-Equalizer-v3.22.8-Firefox.zip**](https://github.com/Maximka1993271/SoundForge-Equalizer/releases/download/v3.22.8-firefox/SoundForge-Equalizer-v3.22.8-Firefox.zip)
2. Extract to any folder
3. Open Firefox → `about:debugging#/runtime/this-firefox`
4. Click **"Load Temporary Add-on"**
5. Select `manifest.json` from the extracted **Firefox** folder

---

#### Option 3 — Disable Signature Verification (for permanent install)

Firefox blocks unsigned extensions by default. To install this extension permanently, you need to disable signature verification:

1. Open Firefox and type in the address bar: `about:config`
2. Click **"Accept the Risk and Continue"**
3. In the search bar, type: `xpinstall.signatures.required`
4. Double-click on the preference to set it to **`false`**
5. **Restart Firefox**
6. After restart, go to `about:addons` → click the gear icon ⚙️
7. Select **"Install Add-on From File..."**
8. Choose `manifest.json` from the extracted **Firefox** folder

---

#### Option 4 — Disable Signature Verification (via user.js)

1. Close Firefox
2. Open your Firefox profile folder:
   - Windows: `%APPDATA%\Mozilla\Firefox\Profiles\`
   - Linux: `~/.mozilla/firefox/`
   - macOS: `~/Library/Application Support/Firefox/Profiles/`
3. Find your profile folder (e.g., `xxxxxxxx.default-release`)
4. Create a file named `user.js` in the profile folder
5. Add this line: `user_pref("xpinstall.signatures.required", false);`
6. Save the file and restart Firefox

---

#### Option 5 — Use Firefox ESR (Enterprise)

If you're using **Firefox ESR** (Extended Support Release), signature verification is more flexible:

1. Download [**soundforge_equalizer-3.22.8.xpi**](https://github.com/Maximka1993271/SoundForge-Equalizer/releases/download/v3.22.8-firefox/soundforge_equalizer-3.22.8.xpi)
2. Drag and drop the `.xpi` file into Firefox ESR
3. Click **"Add"**

> **Note:** Firefox ESR 153.0+ has improved support for unsigned extensions in enterprise environments.

---

### 🔸 Installation Summary

| Method | Difficulty | Permanent | Notes |
|--------|------------|-----------|-------|
| **XPI Drag & Drop** | ⭐ Easy | ❌ Temporary | Quickest method |
| **ZIP via about:debugging** | ⭐ Easy | ❌ Temporary | Good for testing |
| **about:config disable** | ⭐⭐ Medium | ✅ Permanent | Requires restart |
| **user.js method** | ⭐⭐⭐ Hard | ✅ Permanent | For advanced users |
| **Firefox ESR** | ⭐ Easy | ✅ Permanent | Enterprise version |

---

### ⚠️ Important Security Note

> **Disabling signature verification makes Firefox less secure** — only install extensions you trust.  
> SoundForge Equalizer is **open source** and you can review the code at any time.

---

## 📁 Structure
SoundForge-Equalizer/
├── 📁 Microsoft Edge/ # Edge/Chromium version (MV3)
│ ├── background.js
│ ├── inject.js
│ ├── manifest.json
│ ├── popup.html
│ ├── popup.js
│ ├── style.css
│ ├── window.html
│ ├── window.js
│ ├── window.css
│ ├── 📁 features/
│ ├── 📁 icons/
│ └── 📁 modules/
├── 📁 Firefox/ # Firefox version (MV2)
│ ├── background.js
│ ├── inject.js
│ ├── manifest.json
│ ├── popup.html
│ ├── popup.js
│ ├── style.css
│ ├── window.html
│ ├── window.js
│ ├── window.css
│ ├── 📁 features/
│ ├── 📁 icons/
│ └── 📁 modules/
└── 📁 Screenshots/ # Screenshots
├── Full Equalizer.png
├── On Player.png
├── soundforge-full-interfac.png
└── soundforge-light-ui.png


---

## 🛠️ Technologies

| Technology | Description |
|------------|-------------|
| **Manifest V3** | Chrome extension standard |
| **Manifest V2** | Firefox extension standard |
| **Web Audio API** | Audio processing |
| **Chrome Extensions API** | Browser integration |
| **CSS3** | Dark/Light/System themes |
| **JavaScript (ES Modules)** | Modular architecture |

---

## 📊 Statistics

- **10** EQ bands
- **50** built-in presets
- **4** visualization effects
- **3** languages (RU, UA, EN)
- **26** files in repository
- **14** modules
- **2** browser builds supported (Chromium + Firefox)

---

## 📝 License

MIT License

---

## 👤 Author

**Maxim Melnikov**

[GitHub](https://github.com/Maximka1993271)

---

<p align="center">
  <b>Made with ❤️</b><br/>
  <b>Maxim Melnikov</b> — <a href="https://github.com/Maximka1993271">@Maximka1993271</a>
</p>

<p align="center">
  <sub>SoundForge Equalizer v3.22.8 — 10 August 2026</sub><br/>
  <sub>🔓 Open Source — fully open source code</sub>
</p>
