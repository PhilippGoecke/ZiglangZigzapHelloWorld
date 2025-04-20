podman build --no-cache --rm -f Containerfile -t zigzag:demo .
podman run --interactive --tty -p 3000:3000 zigzag:demo
echo "browse http://localhost:3000/?name=test"
