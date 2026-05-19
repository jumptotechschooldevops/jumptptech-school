---
title: "Git install"
description: "Windows — Install Git (step by step)            Option A — Easiest (official..."
published: 2025-11-08
source: "https://dev.to/jumptotech/git-install-579i"
tags: []
---

# Git install


# Windows — Install Git (step by step)

## Option A — Easiest (official installer)

1. **Download**

   * Go to: [https://git-scm.com/download/win](https://git-scm.com/download/win) (downloads start automatically).
   * You’ll get something like `Git-<version>-64-bit.exe`.

2. **Run the installer**

   * Double-click the `.exe`.
   * When the wizard asks:

     * **Adjusting your PATH** → choose **“Git from the command line and also from 3rd-party software”**.
     * **Default editor** → choose **Vim** (default) or pick **Notepad++/VS Code** if you prefer.
     * **Let Git decide line endings** → choose **“Checkout Windows-style, commit Unix-style (recommended)”**.
     * **Git Credential Manager** → **Enable** (recommended).
     * **SSH executable** → **Use bundled OpenSSH**.
     * **Terminal emulator** → **Use Windows’ default console** (or MinTTY if you like).
     * **Enable file system caching** → **Yes**.
     * Leave other defaults unless you know you need something else.

3. **Verify installation**

   * Open **Command Prompt** or **PowerShell** and run:

     ```powershell
     git --version
     ```

     You should see a version number.

4. **Configure your identity**

   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```

5. **(Optional but recommended) Set default branch name to `main`**

   ```powershell
   git config --global init.defaultBranch main
   ```

6. **(Optional) Improve credential & line ending behavior**

   ```powershell
   git config --global core.autocrlf true
   git config --global credential.helper manager
   ```

7. **(Optional) Install Git LFS (for large files)**

   * Re-run the Git installer and tick **Git LFS**, or:

     ```powershell
     winget install Git.GitLFS
     git lfs install
     ```

## Option B — Using Winget (built-in on modern Windows 10/11)

```powershell
winget install --id Git.Git -e
git --version
```

## Option C — Using Chocolatey (if you already use choco)

```powershell
choco install git -y
git --version
```

---

# macOS — Install Git (step by step)

## Option A — Using Homebrew (recommended if you already use brew)

1. **Install Homebrew (if you don’t have it)**

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   brew update
   ```
2. **Install Git**

   ```bash
   brew install git
   git --version
   ```

## Option B — Xcode Command Line Tools (no Homebrew needed)

1. Run:

   ```bash
   xcode-select --install
   ```
2. In the popup, choose **Install**.
3. Verify:

   ```bash
   git --version
   ```

## Option C — Official macOS installer

1. Download the latest `.pkg` from [https://git-scm.com/download/mac](https://git-scm.com/download/mac)
2. Open the `.pkg` → follow the prompts.
3. Verify:

   ```bash
   git --version
   ```

## Configure Git on macOS

1. **Identity**

   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```
2. **Default branch**

   ```bash
   git config --global init.defaultBranch main
   ```
3. **Credentials stored in Keychain**

   ```bash
   git config --global credential.helper osxkeychain
   ```

---

# One-time SSH setup (Windows & macOS)

Use this if you’ll push to GitHub/GitLab/Bitbucket over SSH (recommended for fewer password prompts).

1. **Generate a key (ed25519)**

   ```bash
   ssh-keygen -t ed25519 -C "you@example.com"
   ```

   * Press **Enter** to accept default location (`~/.ssh/id_ed25519`).
   * Optionally set a passphrase.

2. **Start the SSH agent & add your key**

   * **macOS (zsh/bash):**

     ```bash
     eval "$(ssh-agent -s)"
     ssh-add ~/.ssh/id_ed25519
     ```
   * **Windows PowerShell (Git Bash similar):**

     ```powershell
     eval "$(ssh-agent -s)"
     ssh-add ~/.ssh/id_ed25519
     ```

3. **Copy your public key**

   * macOS:

     ```bash
     pbcopy < ~/.ssh/id_ed25519.pub
     ```
   * Windows (PowerShell):

     ```powershell
     Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | Set-Clipboard
     ```

4. **Add to your Git host**

   * GitHub: **Settings → SSH and GPG keys → New SSH key** → paste → Save.
   * GitLab/Bitbucket: similar path under **SSH Keys**.

5. **Test**

   ```bash
   ssh -T git@github.com
   ```

   You should see a success message (first time may ask to trust the host).

---

# Quick sanity test (both platforms)

```bash
mkdir git-test && cd git-test
git init
echo "hello" > README.md
git add README.md
git commit -m "first commit"
git log --oneline
```

---

# Keeping Git up to date

* **Windows (winget):**

  ```powershell
  winget upgrade Git.Git
  ```
* **Windows (installer):** download/run the newest `.exe` from git-scm.com; it upgrades in place.
* **macOS (Homebrew):**

  ```bash
  brew upgrade git
  ```
* **macOS (Xcode CLT):**

  * Run `softwareupdate --all --install --force` or reinstall CLT with `xcode-select --install`.

---

# Common issues & fixes

* **`git: command not found`**

  * Windows: close/reopen terminal; ensure Git is on PATH (re-run installer and select PATH option).
  * macOS: install via `xcode-select --install` or `brew install git`.

* **Corporate proxy blocks**
  Configure Git to use your proxy:

  ```bash
  git config --global http.proxy http://USER:PASS@proxy.company.com:8080
  git config --global https.proxy http://USER:PASS@proxy.company.com:8080
  ```

* **Permission denied (publickey)**
  Your SSH key isn’t added or not uploaded to Git host. Re-run the SSH steps above and test with:

  ```bash
  ssh -T git@github.com
  ```

* **Multiple Git versions on macOS**
  Check which Git runs:

  ```bash
  which git
  ```

  Prefer Homebrew Git (`/usr/local/bin/git` on Intel, `/opt/homebrew/bin/git` on Apple Silicon). If needed, adjust your shell PATH to put Homebrew first.



