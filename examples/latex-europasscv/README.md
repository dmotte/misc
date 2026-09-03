# latex-europasscv

This is an example of how to create a **Europass CV** with **LaTeX** (_TeX Live_) running in a **Podman** container.

First of all, we need to build a _Podman_ image with **TeX Live Full** installed:

```bash
podman build -t img-debian-texlive:latest - << 'EOF'
# syntax=docker/dockerfile:1

FROM docker.io/library/debian:13

RUN <<'EOF2' /bin/bash -e
    apt-get update
    apt-get install -y texlive-full
    rm -rf /var/lib/apt/lists/*
EOF2

WORKDIR /v
EOF
```

> **Note**: this can take **a lot of time** and the resulting image will be **very big** (8+ GB)

Then download the [Europass CV](https://www.overleaf.com/latex/templates/europass-cv/kpcsxfcfvxhx) template, customize it and convert it to **PDF**:

```bash
podman run --rm -v.:/v img-debian-texlive pdflatex europasscv_en.tex
```

## Tips

:bulb: If you get an error like `LaTeX Warning: Reference 'LastPage' on page 1 undefined on input line 123` just try to **run the command twice**. This is because _LaTeX_ can't know yet how many pages there will be on the first run.

:bulb: If you need some cool **icons** in your document, check out `\usepackage{fontawesome5}`.

## Links

- https://www.overleaf.com/latex/templates/europass-cv/kpcsxfcfvxhx
- https://github.com/gmazzamuto/europasscv
- https://www.devrandom.it/software/europasscv/
- https://ctan.mirror.garr.it/mirrors/ctan/macros/latex/contrib/europasscv/europasscv.pdf
