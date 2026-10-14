#!/usr/bin/env python3
"""
Discover Docker images and output build matrices grouped by dependency levels.
"""
import argparse
import glob
import json
import os
import re
import subprocess
import sys


def get_git_changed_files(base_ref=None, before_sha=None):
    """Determine changed files using git."""
    changed_files = set()
    try:
        # Case 1: Push event with a valid before SHA
        if before_sha and not re.match(r"^0+$", before_sha):
            cmd = ["git", "diff", "--name-only", before_sha, "HEAD"]
            res = subprocess.run(cmd, capture_output=True, text=True, check=True)
            for line in res.stdout.splitlines():
                if line.strip():
                    changed_files.add(line.strip())
            return sorted(list(changed_files))

        # Case 2: Pull Request event with base_ref
        if base_ref:
            # Try triple-dot diff first (merge-base)
            diff_spec = f"{base_ref}...HEAD"
            res = subprocess.run(["git", "diff", "--name-only", diff_spec], capture_output=True, text=True)
            if res.returncode == 0 and res.stdout.strip():
                for line in res.stdout.splitlines():
                    if line.strip():
                        changed_files.add(line.strip())
                return sorted(list(changed_files))
            
            # Fallback to double-dot
            res = subprocess.run(["git", "diff", "--name-only", base_ref, "HEAD"], capture_output=True, text=True)
            if res.returncode == 0:
                for line in res.stdout.splitlines():
                    if line.strip():
                        changed_files.add(line.strip())
                return sorted(list(changed_files))

        # Case 3: Fallback to HEAD~1
        res = subprocess.run(["git", "diff", "--name-only", "HEAD~1", "HEAD"], capture_output=True, text=True)
        if res.returncode == 0:
            for line in res.stdout.splitlines():
                if line.strip():
                    changed_files.add(line.strip())
            return sorted(list(changed_files))

    except Exception as exc:
        print(f"Warning: git diff command failed: {exc}", file=sys.stderr)

    return sorted(list(changed_files))


def scan_images(repo_root="."):
    """
    Scan the images/ directory for Dockerfiles.
    Returns a dict mapping 'image:variant' to metadata including internal parent.
    """
    images_dir = os.path.join(repo_root, "images")
    pattern = os.path.join(images_dir, "*", "*", "Dockerfile")
    images = {}

    for path in sorted(glob.glob(pattern)):
        rel_path = os.path.relpath(path, repo_root)
        parts = rel_path.split(os.sep)
        # parts: ['images', '<image>', '<variant>', 'Dockerfile']
        if len(parts) < 4:
            continue
        image = parts[1]
        variant = parts[2]
        if variant == ".build":
            continue

        key = f"{image}:{variant}"
        # For base-gpu-notebook, Dockerfiles are generated into .build/<variant>
        if image == "base-gpu-notebook":
            context = f"images/base-gpu-notebook/.build/{variant}"
        else:
            context = f"images/{image}/{variant}"

        with open(path, "r", encoding="utf-8") as f:
            content = f.read()

        # Check for internal parent image in quay.io or ghcr.io
        # e.g. quay.io/a2s-institute/base-gpu-notebook:cuda12-pytorch-2.2.2
        parent_match = re.search(
            r"(?:quay\.io|ghcr\.io)/[a-zA-Z0-9_\-]+/([a-zA-Z0-9_\-]+):([a-zA-Z0-9_\.\-]+)",
            content
        )
        parent = f"{parent_match.group(1)}:{parent_match.group(2)}" if parent_match else None

        images[key] = {
            "image": image,
            "variant": variant,
            "context": context,
            "parent": parent,
            "source_dir": f"images/{image}/{variant}",
            "dockerfile": rel_path
        }

    # Keep internal parents only if they exist in the repository
    for k, v in images.items():
        if v["parent"] not in images:
            v["parent"] = None

    return images


def compute_levels(images):
    """
    Compute topological dependency level for each image.
    Level 0: No internal parents (foundation, k8s-hub, root notebooks).
    Level N: Parent is at Level N-1.
    """
    levels = {}

    def get_level(key, visited=None):
        if visited is None:
            visited = set()
        if key in visited:
            raise ValueError(f"Cyclic dependency detected at {key}")
        if key in levels:
            return levels[key]

        visited.add(key)
        item = images[key]
        if not item["parent"]:
            levels[key] = 0
            return 0

        lvl = 1 + get_level(item["parent"], visited)
        levels[key] = lvl
        return lvl

    for k in images:
        get_level(k)

    return levels


def filter_images_to_build(images, changed_files, build_all=False, filter_image=None, filter_variant=None):
    """
    Determine which images should be built.
    Includes cascading to downstream children if a parent image is rebuilt.
    """
    if build_all:
        return set(images.keys())

    if filter_image:
        selected = set()
        for k, v in images.items():
            if v["image"] == filter_image:
                if filter_variant and v["variant"] != filter_variant:
                    continue
                selected.add(k)
        return selected

    selected = set()

    # Check shared files for base-gpu-notebook
    base_gpu_shared = [
        "images/base-gpu-notebook/Dockerfile.libs",
        "images/base-gpu-notebook/generate_dockerfile.sh",
        "images/base-gpu-notebook/user-dirs.defaults"
    ]
    if any(f in changed_files for f in base_gpu_shared):
        for k, v in images.items():
            if v["image"] == "base-gpu-notebook":
                selected.add(k)

    for f in changed_files:
        # Ignore documentation and assets
        if f.endswith((".md", ".png", ".jpg", ".jpeg", ".svg", ".gitignore")):
            continue
        parts = f.split("/")
        if len(parts) >= 3 and parts[0] == "images":
            img = parts[1]
            var = parts[2]
            key = f"{img}:{var}"
            if key in images:
                selected.add(key)

    # Cascade to dependent images: if parent changed, rebuild child
    added = True
    while added:
        added = False
        for k, v in images.items():
            if k not in selected and v["parent"] in selected:
                selected.add(k)
                added = True

    return selected


def format_matrix(image_list):
    """Format a list of image dicts into GitHub Actions matrix JSON."""
    if not image_list:
        # Dummy matrix for skipped jobs to avoid expression errors
        dummy = {"include": [{"image": "none", "variant": "none", "context": "none"}]}
        return json.dumps(dummy), "false"

    items = []
    for item in sorted(image_list, key=lambda x: (x["image"], x["variant"])):
        items.append({
            "image": item["image"],
            "variant": item["variant"],
            "context": item["context"]
        })

    return json.dumps({"include": items}), "true"


def set_github_output(name, value):
    """Write an output parameter to $GITHUB_OUTPUT."""
    output_file = os.environ.get("GITHUB_OUTPUT")
    if output_file:
        with open(output_file, "a", encoding="utf-8") as f:
            f.write(f"{name}={value}\n")
    print(f"[OUTPUT] {name}={value}")


def main():
    parser = argparse.ArgumentParser(description="Discover and group Docker images by dependency level.")
    parser.add_argument("--event-name", default=os.environ.get("GITHUB_EVENT_NAME", "push"),
                        help="GitHub event name (push, pull_request, schedule, workflow_dispatch)")
    parser.add_argument("--base-ref", default=None,
                        help="Base branch/ref for pull requests (e.g. origin/master)")
    parser.add_argument("--before-sha", default=None,
                        help="Before commit SHA for push events")
    parser.add_argument("--build-all", action="store_true",
                        help="Force building all images")
    parser.add_argument("--image", default="",
                        help="Filter by specific image name")
    parser.add_argument("--variant", default="",
                        help="Filter by specific variant name")
    parser.add_argument("--max-levels", type=int, default=4,
                        help="Number of dependency levels to output (default: 4, 0-3)")

    args = parser.parse_args()

    # Determine if building all
    build_all = args.build_all or (args.event_name == "schedule")
    filter_image = args.image.strip() if args.image else None
    filter_variant = args.variant.strip() if args.variant else None

    images = scan_images()
    levels = compute_levels(images)

    base_ref = args.base_ref.strip() if args.base_ref and args.base_ref.strip() else None
    before_sha = args.before_sha.strip() if args.before_sha and args.before_sha.strip() else None

    changed_files = []
    if not build_all and not filter_image:
        changed_files = get_git_changed_files(base_ref=base_ref, before_sha=before_sha)
        print(f"Changed files detected ({len(changed_files)}):")
        for f in changed_files:
            print(f"  - {f}")

    to_build = filter_images_to_build(
        images=images,
        changed_files=changed_files,
        build_all=build_all,
        filter_image=filter_image,
        filter_variant=filter_variant
    )

    print(f"\nImages to build ({len(to_build)} of {len(images)}):")
    for k in sorted(to_build):
        print(f"  - {k} (Level {levels[k]}, parent={images[k]['parent']})")

    # Group into levels
    level_buckets = {lvl: [] for lvl in range(args.max_levels)}
    for k in to_build:
        lvl = levels[k]
        if lvl < args.max_levels:
            level_buckets[lvl].append(images[k])
        else:
            # Place any higher level into the highest supported level
            level_buckets[args.max_levels - 1].append(images[k])

    print("\nMatrix outputs:")
    for lvl in range(args.max_levels):
        matrix_json, has_items = format_matrix(level_buckets[lvl])
        set_github_output(f"matrix_level_{lvl}", matrix_json)
        set_github_output(f"has_level_{lvl}", has_items)


if __name__ == "__main__":
    main()
