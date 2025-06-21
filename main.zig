const std = @import("std");
const zap = @import("zap");

fn on_request(r: zap.Request) !void {
  if (r.path) |the_path| {
    std.debug.print("PATH: {s}\n", .{the_path});
  }

  if (r.query) |the_query| {
    std.debug.print("QUERY: {s}\n", .{the_query});
  }

  var arg_it = r.getParamSlices();
  while (arg_it.next()) |param| {
    std.log.info("ParamStr `{s}` is `{s}`", .{ param.name, param.value });
  }

  var name = "World";
  var params = r.getParamSlices();
  if (params.next()) |param| {
    name = param.value;
  }
  const body = try std.fmt.allocPrint(r.allocator(), "<html><body><h1>Hello {s}!</h1></body></html>", .{name});

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
