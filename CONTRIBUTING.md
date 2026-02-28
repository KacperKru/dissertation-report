# Contributing to qdissertation

> SPDX-FileCopyrightText: 2026 Frank Langbein <frank@langbein.org>\
> SPDX-License-Identifier: LPPL-1.3c

Thank you for your interest in contributing. This document explains how to contribute to the **qdissertation** LaTeX class and template.

## How to contribute

1. **Create a branch**, make your changes, **build and test** (see below).
2. **Open a pull request** (or merge request) against the default branch. Describe what you changed and why.

### Build and test

- **Build the PDF:** `make` or `make all` (requires latexmk, pdflatex/xelatex/lualatex, makeglossaries, bibtex).
- **Quality checks:** `make check` runs REUSE lint. Fix any `reuse lint` issues before submitting.
- **Clean build (optional):** `make distclean && make` to ensure a full rebuild.

### Making your changes

- **Class (`qdissertation.cls`):** Keep the same style (comments, spacing). Do not remove or alter SPDX copyright/license lines at the top.
- **Template (`.tex`, `.bib`, etc.):** Add SPDX headers to new files; see [REUSE](https://reuse.software) and existing files.
- **Other files:** Use the same license and copyright as the rest of the project (LPPL-1.3c).

## License and copyright

By contributing, you agree that your contributions will be licensed under the same terms as the project: **LPPL-1.3c**. Add your copyright to the SPDX header of files you create or substantially modify.
