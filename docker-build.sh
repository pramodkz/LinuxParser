#!/bin/bash
# LinuxParser Docker Build Script

set -e

if [[ "$1" == "--run-fast" ]]; then
    echo "⚡ Building LinuxParser Docker Image (with cache)..."
    echo ""
    docker build -t linuxparser:latest .
else
    echo "🐳 Building LinuxParser Docker Image..."
    echo ""
    # Build the image (no cache to ensure latest changes are included)
    docker build --no-cache -t linuxparser:latest .
fi

echo ""
echo "✅ Build complete!"
echo ""
echo "Image: linuxparser:latest"
docker images | grep linuxparser

# Check for run arguments
if [[ "$1" == "--run" ]]; then
    echo ""
    echo "🚀 Parameter --run detected. Restarting container..."

    echo "Stopping linuxparser..."
    docker stop linuxparser 2>/dev/null || true

    echo "Removing linuxparser..."
    docker rm linuxparser 2>/dev/null || true

    echo "Starting new container..."
    docker run -d -p 8000:8000 --name linuxparser -e WEBAPP_DEBUG=1 linuxparser:latest

    echo ""
    echo "✅ Container is running!"
elif [[ "$1" == "--run-public" ]]; then
    echo ""
    echo "🚀 Parameter --run-public detected. Restarting container in PUBLIC MODE..."
    
    echo "Stopping linuxparser..."
    docker stop linuxparser 2>/dev/null || true

    echo "Removing linuxparser..."
    docker rm linuxparser 2>/dev/null || true

    echo "Starting new container with PUBLIC_MODE=true..."
    docker run -d -p 8000:8000 --name linuxparser -e PUBLIC_MODE=true linuxparser:latest
    
    echo ""
    echo "✅ Container is running in PUBLIC MODE!"
    echo "   - No report storage"
    echo "   - Saved Reports browser disabled"
    echo "   - Reports deleted after viewing"
    echo "   - Audit logging enabled (JSON format)"
    echo ""
    echo "📊 To view audit logs:"
    echo "   docker logs -f linuxparser | grep 'AUDIT'"
    echo ""
    echo "   Or use the helper script:"
    echo "   ./view-audit-logs.sh live"
    echo "   ./view-audit-logs.sh stats"
elif [[ "$1" == "--run-fast" ]]; then
    echo ""
    echo "⚡ Restarting container with freshly cached build..."

    echo "Stopping linuxparser..."
    docker stop linuxparser 2>/dev/null || true

    echo "Removing linuxparser..."
    docker rm linuxparser 2>/dev/null || true

    echo "Starting new container..."
    docker run -d -p 8000:8000 --name linuxparser -e WEBAPP_DEBUG=1 linuxparser:latest

    echo ""
    echo "✅ Container is running!"

elif [[ "$1" == "--logs" ]]; then
    echo ""
    echo "📊 Showing audit logs from linuxparser container..."
    echo "   Press Ctrl+C to stop"
    echo ""
    docker logs -f linuxparser 2>&1 | grep --line-buffered "AUDIT"
else
    echo ""
    echo "To run manually:"
    echo "  docker run -d -p 8000:8000 --name linuxparser linuxparser:latest"
    echo ""
    echo "To run in public mode (no data retention + audit logging):"
    echo "  docker run -d -p 8000:8000 --name linuxparser -e PUBLIC_MODE=true linuxparser:latest"
    echo "  # View logs: docker logs -f linuxparser | grep 'AUDIT'"
    echo ""
    echo "To run with persistent storage:"
    echo "  docker run -d -p 8000:8000 --name linuxparser -v linuxparser_uploads:/app/webapp/uploads -v linuxparser_outputs:/app/webapp/outputs linuxparser:latest"
    echo ""
    echo "Or use docker-compose:"
    echo "  docker-compose up -d                              # Private mode"
    echo "  docker-compose -f docker-compose.public.yml up -d  # Public mode with audit logging"
    echo ""
    echo "Quick test options:"
    echo "  ./docker-build.sh --run         # Build (no cache) and run in private mode with debug"
    echo "  ./docker-build.sh --run-fast    # Build (with cache) and run in private mode with debug"
    echo "  ./docker-build.sh --run-public  # Build and run in public mode with audit logging"
    echo "  ./docker-build.sh --logs        # View audit logs from running container"
fi