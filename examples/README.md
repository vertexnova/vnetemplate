# VneTemplate Examples

This directory contains examples demonstrating the VneTemplate API.

## Building Examples

From the project root:

```bash
cmake -B build -DVNE_TEMPLATE_EXAMPLES=ON
cmake --build build
```

Or use the dev preset (enables tests and examples):

```bash
cmake -B build -DVNE_TEMPLATE_DEV=ON
cmake --build build
```

Executables are placed in `build/bin/examples/`.

## Available Examples

### 01_hello_template — Getting Started

Minimal usage: call `vne::template_ns::hello()` and `get_version()`.

**Run:** `./build/bin/examples/example_01_hello_template`

## Quick Reference

| Example              | Focus          | Key Concepts              |
|----------------------|----------------|---------------------------|
| 01_hello_template    | Getting started| hello(), get_version()   |
