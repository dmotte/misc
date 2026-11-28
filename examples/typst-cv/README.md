# typst-cv

This is an example of how to create a **CV** (_Curriculum Vitae_) with **Typst** running in a **Podman** container.

First of all, **get all the required files**; see: [Fonts](#fonts), [Icons](#icons).

```bash
podman run --pull=always -t --rm -v.:/v -w/v ghcr.io/typst/typst:latest compile --ignore-system-fonts --font-path=fonts main.{typ,pdf}
```

To check for **ATS compliance**:

```bash
pdftotext main.pdf - # Preferable
pdftotext -layout main.pdf -
```

You can also test it with [OpenResume's online parser](https://www.open-resume.com/resume-parser).

## Fonts

### Liberation Sans

**Source**: Debian 13 (trixie) package `fonts-liberation` (https://packages.debian.org/trixie/fonts-liberation) (version `1:2.1.5-3`)

```bash
cp -vtfonts /usr/share/fonts/truetype/liberation/LiberationSans-*

sha256sum -c <<'EOF'
352e9dc2be89f210dbd3c0fd5dfaf97135de70e0beb5f22378601861462493a7  fonts/LiberationSans-BoldItalic.ttf
1b5f2da6f4cadce4c05b9ecebe3a6fcd374eb95ae443605e799f4c3287978939  fonts/LiberationSans-Bold.ttf
93ff5260834141b6f9d8f2b846d427f3a5dc492dbdce8ebdad406e38a38f34bb  fonts/LiberationSans-Italic.ttf
bade59d822652f76e6941aa87b40a87c13d1cc70db98ededb5011127efafd1d3  fonts/LiberationSans-Regular.ttf
EOF
```

## Icons

### Material Design Icons

**Source**: [Iconify JSON Downloader](https://ecstrema.github.io/iconify-typst/)

```bash
curl -fLoicons/mdi.json 'https://raw.githubusercontent.com/iconify/icon-sets/81ad501f19cc13e548e4cb6a9c63a3873c87262a/json/mdi.json'

echo 'cf9b89dda466f1c384af19d3c7bf835c3c1e75eccf313f7821ac48c14f2c8c7b icons/mdi.json' | sha256sum -c
```
