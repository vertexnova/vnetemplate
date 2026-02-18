# vnelogging

This directory should contain the **VertexNova logging** library (vnelogging).

It is not shipped with the template. Add it as a git submodule or clone the repository here, for example:

```bash
# From the project root, with submodule:
git submodule add <vnelogging-repo-url> deps/internal/vnelogging
git submodule update --init --recursive
```

Use the branch or tag recommended by your team. The main CMakeLists.txt uses `vne_use_dep(TARGET vne::logging ...)` to include this project when present.

Without vnelogging, the template library will still configure and build but will not link against `vne::logging`.
