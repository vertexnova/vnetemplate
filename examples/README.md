# VneTemplate Examples

This directory contains examples demonstrating the VneTemplate API.

## Building Examples

From the project root (use `build/shared` or `build/static`):

```bash
cmake -B build/shared -DVNE_TEMPLATE_EXAMPLES=ON
cmake --build build/shared
```

Alternatively, `-DVNE_TEMPLATE_DEV=ON` enables both tests and examples.

Executables are placed in `build/shared/bin/examples/` (or `build/static/bin/examples/`).

## Available Examples

### 01_hello_template — Getting Started

Minimal usage: call `vne::template_ns::hello()` and `get_version()`.

**Run:** `./build/shared/bin/examples/example_01_hello_template`

## Quick Reference

| Example              | Focus          | Key Concepts              |
|----------------------|----------------|---------------------------|
| 01_hello_template    | Getting started| hello(), get_version()   |
