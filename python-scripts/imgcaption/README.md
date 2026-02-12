# imgcaption

Simple Python script to generate **descriptive texts** (**captions**) for images, using the **[Hugging Face Transformers](https://huggingface.co/transformers)** library with the **`Salesforce/blip-image-captioning-base`** model. It is basically just a **wrapper** around such library.

Inspired by:

- [Building an Image Captioning Model Using Salesforce's BLIP Model - by Pranav Kumar - Medium](https://medium.com/@k.pranav_22/building-an-image-captioning-model-using-salesforces-blip-model-3b80a4f032c4)
- [What is Image Captioning and How to use Python to Generate Caption from an Image - by Jim Wang - Medium](https://medium.com/@jimwang3589/what-is-image-captioning-and-how-to-use-python-to-generate-caption-from-an-image-98a9eb6be06d)
- [An Introduction to Image Captioning with BLIP - Aggregata](https://aggregata.de/blip/)

## Usage

> **Important**: this has been tested with **Python 3.13.5** on **Debian 13** (_trixie_).

Set up a **Python venv** (virtual environment) and install some packages inside it:

```bash
python3 -mvenv venv
venv/bin/python3 -mpip install -r requirements.txt
```

Then you can use the script like this:

```bash
time printf '%s\n' img/*.jpg | venv/bin/python3 main.py
```
