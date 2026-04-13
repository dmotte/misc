# html-to-pdf

This is an example of how to **generate a PDF from an HTML page** programmatically.

You can use _Chromium_'s or _Google Chrome_'s command-line like this:

```bash
chromium --headless --no-sandbox --disable-gpu \
    --run-all-compositor-stages-before-draw --virtual-time-budget=5000 \
    --force-device-scale-factor=1 \
    --no-pdf-header-footer --print-to-pdf=example.pdf example.html
```

That's basically equivalent to opening the HTML file with the _Chromium_ browser, pressing `CTRL+P` and selecting **Save as PDF**.
