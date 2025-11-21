#!/bin/bash

set -e

# Function to get the next version tag
get_next_version() {
    # Get the latest tag that matches v0.0.* pattern
    LATEST_TAG=$(git tag -l "v0.0.*" | sort -V | tail -n1)
    
    if [ -z "$LATEST_TAG" ]; then
        echo "v0.0.1"
    else
        # Extract the number after the last dot
        PATCH_VERSION=$(echo "$LATEST_TAG" | sed 's/.*\.//')
        NEXT_PATCH=$((PATCH_VERSION + 1))
        echo "v0.0.$NEXT_PATCH"
    fi
}

# Parse arguments
if [ $# -eq 0 ]; then
    TAG=$(get_next_version)
    TITLE="Release $TAG"
elif [ $# -eq 1 ]; then
    TAG="$1"
    TITLE="Release $TAG"
elif [ $# -eq 2 ]; then
    TAG="$1"
    TITLE="$2"
else
    echo "Usage: $0 [tag] [title]"
    echo "Examples:"
    echo "  $0                    # Auto-increment version"
    echo "  $0 v1.0.0             # Use specific tag"
    echo "  $0 v1.0.0 'My Release' # Use specific tag and title"
    exit 1
fi

echo "Creating tag: $TAG"
git tag "$TAG"

echo "Pushing tag to remote..."
git push origin "$TAG"

echo "Creating release with assets..."
gh release create "$TAG" \
    --title "$TITLE" \
    --notes "Release $TAG" \
    assets/*

echo "Release $TAG created successfully!"