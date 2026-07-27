const std = @import("std");
const zap = @import("zap");

fn on_request(r: zap.Request) !void {
  if (r.path) |the_path| {
    std.debug.print("PATH: {s}\n", .{the_path});
  }

  if (r.query) |the_query| {
    std.debug.print("QUERY: {s}\n", .{the_query});
  }

  var name: []const u8 = "World";
  var arg_it = r.getParamSlices();
  while (arg_it.next()) |param| {
    std.log.info("ParamStr `{s}` is `{s}`", .{ param.name, param.value });
    if (std.mem.eql(u8, param.name, "name")) {
      name = param.value;
    }
  }

  var buf: [256]u8 = undefined;
  const zig_version = @import("builtin").zig_version_string;
  const body = std.fmt.bufPrint(&buf, "<html><body><h1>Hello, {s}!</h1>\n<h2>Zig version: {s}</h2>\n</body></html>", .{ name, zig_version }) catch return;

  r.sendBody(body) catch return;
}

pub fn main() !void {
  var listener = zap.HttpListener.init(.{
    .port = 3000,
    .on_request = on_request,
    .log = true,
    .max_clients = 100000,
  });
  try listener.listen();

  std.debug.print("Listening on 0.0.0.0:3000\n", .{});

  zap.start(.{
    .threads = 2,
    .workers = 1, // 1 worker enables sharing state between threads
  });
}
