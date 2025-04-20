podman build --no-cache --rm -f Containerfile -t zigzap:demo .
podman run --interactive --tty -p 3000:3000 zigzap:demo
echo "browse http://localhost:3000/?name=test"
