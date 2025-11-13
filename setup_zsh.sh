#!/usr/bin/env bash
# ==============================================
# 🚀 Universal Zsh Setup Script by Raphy
# Compatible: macOS / Ubuntu / Debian / Raspberry Pi OS
# ==============================================

set -e

# --- Detect OS ---------------------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ -f /etc/debian_version ]]; then
  OS="debian"
else
  echo "❌ Unsupported OS."
  exit 1
fi

echo "🔍 Detected OS: $OS"

# --- Function to install packages safely -------------------------------------
install_pkg() {
  local pkg="$1"
  if [[ "$OS" == "macos" ]]; then
    if ! brew list --formula | grep -q "^${pkg}\$"; then
      echo "📦 Installing $pkg with Homebrew..."
      brew install "$pkg"
    fi
  else
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      echo "📦 Installing $pkg with APT..."
      sudo apt install -y "$pkg"
    fi
  fi
}

# --- Step 1: Install Zsh -----------------------------------------------------
if ! command -v zsh >/dev/null 2>&1; then
  echo "💿 Installing Zsh..."
  install_pkg zsh
else
  echo "✅ Zsh already installed."
fi

# --- Step 2: Install Oh My Zsh -----------------------------------------------
ZSH="$HOME/.oh-my-zsh"
if [ ! -d "$ZSH" ]; then
  echo "⚙️ Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh already installed."
fi

# --- Step 3: Install Powerlevel10k ------------------------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "✨ Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM}/themes/powerlevel10k
else
  echo "✅ Powerlevel10k already installed."
fi

# --- Step 4: Install Plugins -------------------------------------------------
plugins=(
  "https://github.com/zsh-users/zsh-autosuggestions"
  "https://github.com/zsh-users/zsh-syntax-highlighting"
)

for repo in "${plugins[@]}"; do
  name=$(basename "$repo")
  dest="${ZSH_CUSTOM}/plugins/${name}"
  if [ ! -d "$dest" ]; then
    echo "🔌 Installing plugin $name..."
    git clone "$repo" "$dest"
  else
    echo "✅ Plugin $name already installed."
  fi
done

# --- Step 5: Generate ~/.zshrc ----------------------------------------------
echo "🧾 Generating ~/.zshrc ..."
cat > ~/.zshrc <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# --- Aliases communs ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'
alias lsd='ls -lhd */'
alias df='df -h'
alias du='du -sh'
alias py='python3'
alias serve='python3 -m http.server'
alias weather='curl wttr.in'
alias ports='sudo lsof -iTCP -sTCP:LISTEN -n -P'

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOF

# --- Step 6: Change default shell to zsh ------------------------------------
if [[ "$SHELL" != *"zsh" ]]; then
  echo "🔄 Changing default shell to Zsh..."
  chsh -s "$(which zsh)"
else
  echo "✅ Zsh already set as default shell."
fi

echo
echo "🎉 Installation complete!"
echo "➡️  Restart your terminal or run: exec zsh"