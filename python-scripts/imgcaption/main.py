#!/usr/bin/env python3

import sys

from PIL import Image
from transformers import BlipProcessor, BlipForConditionalGeneration


def main() -> int:
    print('Loading BLIP processor and model', file=sys.stderr)

    processor: BlipProcessor = BlipProcessor.from_pretrained(
        'Salesforce/blip-image-captioning-base')
    model = BlipForConditionalGeneration.from_pretrained(
        'Salesforce/blip-image-captioning-base')

    print('Starting caption generation loop', file=sys.stderr)

    for line in sys.stdin:
        path = line.strip()

        print(f'Generating caption for image {path}', file=sys.stderr)

        image = Image.open(path).convert('RGB')
        inputs = processor(image, return_tensors='pt')
        outputs = model.generate(**inputs)
        caption = processor.decode(outputs[0], skip_special_tokens=True)

        print(f'{path}|{caption}')

    return 0


if __name__ == '__main__':
    sys.exit(main())
