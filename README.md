# Jimmy's Nix Configs

## Instructions for installing this on MacOS

+ Install lix: `curl -sSf -L https://install.lix.systems/lix | sh -s -- install`
  (do enable flakes)
+ Clone repository: `git clone https://github.com/dimmyjing/nix-config ~/Workspace/nix`
+ Change the config (add a host in `configurations/darwin` and replace
  `configurations/home/jimmy.nix` with your username)
+ Run `git add .` to register all the changes you've made.
+ Go to the root directory of the repository and run `nix run`
+ Launch Karabiner Elements (along with accepting settings)
+ Configure spotlight keybind (Keyboard > Keyboard Shortcuts > Spotlight >
  Set `Show Spotlight search` to `Option Space`)
+ Open Raycast (Configure keybind to `Command Space`)

### Configure Yabai (optional)

It's best to follow the [reference](https://github.com/asmvik/yabai/wiki/Disabling-System-Integrity-Protection)

### Configure Pitchfork (optional)

+ `mise use -g pitchfork`
