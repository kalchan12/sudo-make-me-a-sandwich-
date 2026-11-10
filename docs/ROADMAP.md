# Roadmap

## Done
- Core modular Bash installer with rich TUI + GTK3/Tkinter GUI.
- Nested shared catalog (`catalog/`) — single source of truth parsed by all
  three interfaces (bash CLI, Python TUI, Python GUI).
- Presets (`presets/*.list`) installable with `--profile <name>`;
  `psycho`, `minimal` and `full` ship by default.
- Legacy hardcoded category lists (`modules/*.sh`) removed; per-tool install
  functions now live next to their metadata inside `catalog/`.

## Ideas
- [ ] Fedora/Arch compatibility.
- [ ] Package manager search mode.
- [ ] Per-tool explanations exposed through the GUI detail panel for free
      (currently bash `--explain` and TUI `e<N>` read `core/explanations.sh`).
- [ ] Optional unattended flags for preset runs (`--profile <name> -y`).
- [ ] Dry-run audit: a few installer bodies (e.g. `install_chrome`,
      `install_firefox_dev`) still hit the network before honouring
      `--dry-run`; they should route through guarded helpers.
