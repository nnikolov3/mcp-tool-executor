// DO EVERYTHING WITH LOVE, CARE, HONESTY, TRUTH, TRUST, KINDNESS, RELIABILITY, CONSISTENCY, DISCIPLINE, RESILIENCE, CRAFTSMANSHIP, HUMILITY, ALLIANCE, EXPLICITNESS

const std = @import("std");
const Allocator = std.mem.Allocator;

pub const HttpClient = struct {
    allocator: Allocator,
    client: std.http.Client,
    base_url: []const u8,

    pub fn init(allocator: Allocator, base_url: []const u8) HttpClient {
        return .{
            .allocator = allocator,
            .client = std.http.Client{ .allocator = allocator },
            .base_url = base_url,
        };
    }

    pub fn deinit(self: *HttpClient) void {
        self.client.deinit();
    }

    fn post(self: *HttpClient, path: []const u8, payload: []const u8) ![]u8 {
        const url = try std.fmt.allocPrint(self.allocator, "{s}{s}", .{ self.base_url, path });
        defer self.allocator.free(url);
        const uri = try std.Uri.parse(url);

        // Allocate a buffer for the response. 1MB should be enough for most tool outputs.
        const response_buffer = try self.allocator.alloc(u8, 1024 * 1024);
        defer self.allocator.free(response_buffer);
        
        var response_writer = std.Io.Writer.fixed(response_buffer);

        const result = try self.client.fetch(.{
            .location = .{ .uri = uri },
            .method = .POST,
            .payload = payload,
            .response_writer = &response_writer,
            .keep_alive = false,
        });

        if (result.status != .ok) {
            return error.HttpRequestFailed;
        }

        return try self.allocator.dupe(u8, response_writer.buffered());
    }

    pub fn readFile(self: *HttpClient, path: []const u8) ![]u8 {
        const payload = try std.json.Stringify.valueAlloc(self.allocator, .{ .path = path }, .{});
        defer self.allocator.free(payload);
        return self.post("/read", payload);
    }

    pub fn writeFile(self: *HttpClient, path: []const u8, content: []const u8) !void {
        const payload = try std.json.Stringify.valueAlloc(self.allocator, .{ .path = path, .content = content }, .{});
        defer self.allocator.free(payload);
        const response = try self.post("/write", payload);
        self.allocator.free(response);
    }

    pub fn replaceWholeWord(self: *HttpClient, path: []const u8, old: []const u8, new: []const u8) !void {
        const payload = try std.json.Stringify.valueAlloc(self.allocator, .{ .path = path, .old = old, .new = new }, .{});
        defer self.allocator.free(payload);
        const response = try self.post("/replace-word", payload);
        self.allocator.free(response);
    }

    pub fn replaceText(self: *HttpClient, path: []const u8, old: []const u8, new: []const u8) !void {
        const payload = try std.json.Stringify.valueAlloc(self.allocator, .{ .path = path, .old = old, .new = new }, .{});
        defer self.allocator.free(payload);
        const response = try self.post("/replace-text", payload);
        self.allocator.free(response);
    }
};
