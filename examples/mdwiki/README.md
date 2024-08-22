# mdwiki

MDwiki is a static, **single-file** Markdown-based CMS/Wiki made with only **client-side** Javascript and HTML5.

These are the commands I use to set it up in a local folder:

```bash
curl -fLO 'https://github.com/Dynalon/mdwiki/releases/download/0.6.2/mdwiki-0.6.2.zip'
echo e06f5d99c5cf3a85abdd522a6f2e9a1a9cb669468b29ee970caff3020ba9190a mdwiki-0.6.2.zip | sha256sum -c
unzip mdwiki-0.6.2.zip
cp -T mdwiki-0.6.2/mdwiki.html index.html
sed -i 's/index\.md/README.md/g' index.html
```

Then you can see your local static website with:

```bash
python3 -mhttp.server -b127.0.0.1
xdg-open http://127.0.0.1:8000/
```

## Links

- http://mdwiki.info/
- https://github.com/Dynalon/mdwiki/
