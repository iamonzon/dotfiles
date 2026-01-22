# nix-darwin Migration

## Why
- Declarative Homebrew management (casks/brews auto-install from config)
- macOS system settings managed via Nix (Dock, Finder, keyboard, etc.)
- launchd services management
- Full reproducibility of entire macOS setup

## Steps
- [ ] Install nix-darwin: https://github.com/LnL7/nix-darwin
- [ ] Create `darwin-configuration.nix`
- [ ] Move macOS-specific packages from home.nix to darwin config
- [ ] Add Homebrew casks to declarative config
- [ ] Configure macOS system preferences (optional)
- [ ] Test on a fresh setup

## Resources
- nix-darwin repo: https://github.com/LnL7/nix-darwin
- nix-darwin options: https://daiderd.com/nix-darwin/manual/index.html
- Example configs: https://github.com/search?q=darwin-configuration.nix

## Notes
- Current setup: home-manager with Homebrew in PATH (manual brew management)
- Target: nix-darwin managing Homebrew declaratively
