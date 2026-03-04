#!/usr/bin/env python
"""Image editing via OpenAI-compatible chat.completions multimodal API."""

import argparse
import base64
import os
import sys

import openai


def main():
    parser = argparse.ArgumentParser(description="Edit/combine images with text instructions")
    parser.add_argument("prompt", help="Edit instruction describing desired changes")
    parser.add_argument("-i", "--images", nargs="+", required=True, help="Reference image path(s)")
    parser.add_argument("-o", "--output", default="edited.png", help="Output file path (default: edited.png)")
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

    # Validate image paths
    for img_path in args.images:
        if not os.path.isfile(img_path):
            print(f"Error: Image file not found: {img_path}", file=sys.stderr)
            sys.exit(1)

    client = openai.OpenAI(base_url=base_url, api_key=api_key)

    # Build multimodal content: images first, then text prompt
    content_parts = []
    for img_path in args.images:
        with open(img_path, "rb") as f:
            img_b64 = base64.b64encode(f.read()).decode()
        content_parts.append({
            "type": "image_url",
            "image_url": {"url": f"data:image/png;base64,{img_b64}"}
        })
    content_parts.append({"type": "text", "text": args.prompt})

    print(f"Editing image with {len(args.images)} reference(s)...")
    response = client.chat.completions.create(
        model=args.model,
        messages=[{"role": "user", "content": content_parts}]
    )

    # Extract generated image from response.message.images
    resp = response.model_dump()
    images = resp["choices"][0]["message"].get("images", [])

    if not images:
        content = resp["choices"][0]["message"].get("content", "")
        print(f"Error: No image in response. Model returned: {str(content)[:500]}", file=sys.stderr)
        sys.exit(1)

    img_url = images[0]["image_url"]["url"]
    b64_data = img_url.split(",", 1)[1]
    image_bytes = base64.b64decode(b64_data)

    with open(args.output, "wb") as f:
        f.write(image_bytes)

    print(f"Image saved to: {args.output}")
    print(f"Size: {len(image_bytes)} bytes")


if __name__ == "__main__":
    main()
