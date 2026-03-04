#!/usr/bin/env python
"""Text-to-image generation via OpenAI-compatible API (images.generate endpoint)."""

import argparse
import base64
import os
import sys

import openai


def main():
    parser = argparse.ArgumentParser(description="Generate image from text prompt")
    parser.add_argument("prompt", help="Text description of the image to generate")
    parser.add_argument("-o", "--output", default="generated.png", help="Output file path (default: generated.png)")
    parser.add_argument("-m", "--model", default="gemini-3.1-flash-image-preview", help="Model name")
    args = parser.parse_args()

    base_url = os.environ.get("TEXT_2_IMAGE_BASE_URL")
    api_key = os.environ.get("TEXT_2_IMAGE_API_KEY")

    if not base_url:
        print("Error: TEXT_2_IMAGE_BASE_URL environment variable is not set", file=sys.stderr)
        sys.exit(1)
    if not api_key:
        print("Error: TEXT_2_IMAGE_API_KEY environment variable is not set", file=sys.stderr)
        sys.exit(1)

    client = openai.OpenAI(base_url=base_url, api_key=api_key)

    print(f"Generating image for: {args.prompt}")
    result = client.images.generate(model=args.model, prompt=args.prompt)

    image_base64 = result.data[0].b64_json
    image_bytes = base64.b64decode(image_base64)

    with open(args.output, "wb") as f:
        f.write(image_bytes)

    print(f"Image saved to: {args.output}")
    print(f"Size: {len(image_bytes)} bytes")


if __name__ == "__main__":
    main()
