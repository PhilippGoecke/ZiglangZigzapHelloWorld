FROM debian:bookworm-slim as install

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y \
  && apt install -y --no-install-recommends --no-install-suggests ca-certificates curl xz-utils minisign \
  && rm -rf "/var/lib/apt/lists/*" \
  && rm -rf /var/cache/apt/archives

WORKDIR /ziglang

RUN curl -fsSL https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz --output zig-linux-x86_64-0.14.0.tar.xz \
  && curl https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz.minisig --output zig.tar.xz.minisig \
  && ls -lisah \
  && minisign -V -x zig.tar.xz.minisig -m zig-linux-x86_64-0.14.0.tar.xz -P 'RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U' \
  && tar xf zig-linux-x86_64-0.14.0.tar.xz \
  && mv zig-linux-x86_64-0.14.0/zig /usr/bin/ \
  && mv zig-linux-x86_64-0.14.0/lib/ /usr/lib/zig/ \
  && zig version

FROM debian:bookworm-slim as zigzap

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y \
  && apt install -y --no-install-recommends --no-install-suggests ca-certificates git \
  && rm -rf "/var/lib/apt/lists/*" \
  && rm -rf /var/cache/apt/archives

COPY --from=install /usr/bin/zig /usr/bin/zig
COPY --from=install /usr/lib/zig /usr/lib/zig

WORKDIR /zigzap

RUN zig init \
  && zig fetch --save "git+https://github.com/zigzap/zap#v0.10.1" \
  && echo "const zap = b.dependency(\"zap\", .{ .target = target, .optimize = optimize, .openssl = false, });\nexe.root_module.addImport(\"zap\", zap.module(\"zap\"));\n}" >> build.zig \
  && sed -zi "s/}\nconst/\nconst/g" build.zig

COPY main.zig src/main.zig

EXPOSE 3000

CMD ["zig", "build", "run"]
