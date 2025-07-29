#!/bin/bash
set -e

# WIDIT - WSL is Docker is Tarballs
# Creator script for building custom WSL distributions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_IMAGE=""
DOCKERFILE=""
OUTPUT_NAME="widit-custom-distro"

show_help() {
    cat << EOF
WIDIT Creator - Build custom WSL distributions

Usage: $0 [OPTIONS]

Options:
    --base-image IMAGE      Use a Docker base image (e.g., ubuntu:22.04, alpine:latest)
    --dockerfile PATH       Build from a local Dockerfile
    --output NAME          Output name for the distribution tarball (default: widit-custom-distro)
    --help                 Show this help message

Examples:
    $0 --base-image ubuntu:22.04
    $0 --dockerfile ./my-custom.dockerfile
    $0 --base-image debian:bullseye --output my-debian-wsl

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --base-image)
            BASE_IMAGE="$2"
            shift 2
            ;;
        --dockerfile)
            DOCKERFILE="$2"
            shift 2
            ;;
        --output)
            OUTPUT_NAME="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate arguments
if [[ -z "$BASE_IMAGE" && -z "$DOCKERFILE" ]]; then
    echo "Error: Either --base-image or --dockerfile must be specified"
    show_help
    exit 1
fi

if [[ -n "$BASE_IMAGE" && -n "$DOCKERFILE" ]]; then
    echo "Error: Cannot specify both --base-image and --dockerfile"
    show_help
    exit 1
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

echo "WIDIT Creator starting..."

# Determine the base image to use
if [[ -n "$DOCKERFILE" ]]; then
    echo "Building from Dockerfile: $DOCKERFILE"
    if [[ ! -f "$DOCKERFILE" ]]; then
        echo "Error: Dockerfile not found at $DOCKERFILE"
        exit 1
    fi
    
    # Build the user's Dockerfile first to create a base image
    USER_IMAGE_TAG="widit-user-base:$(date +%s)"
    echo "Building user Dockerfile..."
    docker build -f "$DOCKERFILE" -t "$USER_IMAGE_TAG" "$(dirname "$DOCKERFILE")"
    BASE_IMAGE="$USER_IMAGE_TAG"
    
    # Set up cleanup for the user image
    cleanup_user_image() {
        echo "Cleaning up user base image..."
        docker rmi "$USER_IMAGE_TAG" 2>/dev/null || true
    }
    trap cleanup_user_image EXIT
else
    echo "Using base image: $BASE_IMAGE"
fi

# Build the WSL distribution using wsl.dockerfile
WSL_IMAGE_TAG="widit-wsl:$(date +%s)"
echo "Building WSL distribution from base image: $BASE_IMAGE"
docker build --build-arg BASE_IMAGE="$BASE_IMAGE" -f "$SCRIPT_DIR/wsl.dockerfile" -t "$WSL_IMAGE_TAG" "$SCRIPT_DIR"

# Create container and export as tarball
echo "Creating WSL distribution tarball..."
CONTAINER_ID=$(docker create "$WSL_IMAGE_TAG")
docker export "$CONTAINER_ID" | gzip > "$SCRIPT_DIR/${OUTPUT_NAME}.tar.gz"
docker rm "$CONTAINER_ID"

# Clean up the WSL image
docker rmi "$WSL_IMAGE_TAG"

echo "WSL distribution created successfully: ${OUTPUT_NAME}.tar.gz"
echo ""
echo "To import into WSL, run:"
echo "wsl --import $OUTPUT_NAME C:\\path\\to\\install\\location ${OUTPUT_NAME}.tar.gz"
echo ""
echo "Example:"
echo "wsl --import $OUTPUT_NAME C:\\WSL\\$OUTPUT_NAME ${OUTPUT_NAME}.tar.gz"