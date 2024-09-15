# Stage 1: Build Neovim
FROM ubuntu AS builder

ARG BUILD_APT_DEPS="ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip git binutils wget"
ARG DEBIAN_FRONTEND=noninteractive
ARG TARGET=nightly

RUN apt update && apt upgrade -y && \
  apt install -y ${BUILD_APT_DEPS} && \
  git config --global http.postBuffer 524288000 && \
  git clone --depth 1 --branch ${TARGET} https://github.com/neovim/neovim.git /tmp/neovim && \
  cd /tmp/neovim && \
  make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr/local/ && \
  make install && \
  strip /usr/local/bin/nvim

# Stage 2: Final Image with Neovim and additional tools
FROM ubuntu

# Install runtime dependencies and additional tools
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y \
    curl \
    wget \
    ripgrep \
    tree \
    nodejs \
    npm \
    python3-pip \
    python3-venv \
    git \
		xclip \
		xsel \
		fd-find

# Create and activate a virtual environment for Python
RUN python3 -m venv /usr/local/venv && \
    /usr/local/venv/bin/pip install pynvim ruff

# Install Node.js LSP servers and Tree-sitter CLI globally
RUN npm install -g typescript-language-server vscode-langservers-extracted tree-sitter-cli \
    @fsouza/prettierd eslint_d pyright emmet-ls @tailwindcss/language-server \
		@johnnymorganz/stylua-bin emmet-ls pyright

# Set the virtual environment's Python as the default
ENV PATH="/usr/local/venv/bin:$PATH"

# Copy Neovim from the builder stage
COPY --from=builder /usr/local /usr/local/

# Copy Neovim configuration from local directory
COPY . /root/.config/nvim

# Install Neovim plugins and Mason dependencies during build
RUN nvim --headless +':Lazy! sync' +qall
RUN nvim --headless +':MasonToolsInstallSync all' +qall
RUN nvim --headless +':TSUpdateSync all' +qall

# Mount your Neovim configuration (ensure this directory exists on the host)
VOLUME ["/root/.config/nvim"]

# Set the default command to run Neovim
CMD ["/usr/local/bin/nvim", "/workspace"]
