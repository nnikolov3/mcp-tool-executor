// DO EVERYTHING WITH LOVE, CARE, HONESTY, TRUTH, TRUST, KINDNESS, RELIABILITY, CONSISTENCY, DISCIPLINE, RESILIENCE, CRAFTSMANSHIP, HUMILITY, ALLIANCE, EXPLICITNESS
const std = @import("std");
const Allocator = std.mem.Allocator;
const c = @cImport({
    @cInclude("sqlite3.h");
});

pub const AgentChatEntry = struct {
    id: i64,
    timestamp: []const u8,
    alias: []const u8,
    intent: []const u8,
    status: []const u8,
    semaphore: []const u8,
    notes: []const u8,

    pub fn deinit(self: AgentChatEntry, allocator: Allocator) void {
        allocator.free(self.timestamp);
        allocator.free(self.alias);
        allocator.free(self.intent);
        allocator.free(self.status);
        allocator.free(self.semaphore);
        allocator.free(self.notes);
    }
};

pub const Database = struct {
    handle: *c.sqlite3,
    allocator: Allocator,

    pub fn init(allocator: Allocator, path: []const u8) !Database {
        var handle: ?*c.sqlite3 = null;
        const result_code = c.sqlite3_open(path.ptr, &handle);
        if (result_code != c.SQLITE_OK) {
            return error.SqliteOpenFailed;
        }
        var self = Database{
            .handle = handle.?,
            .allocator = allocator,
        };
        try self.initSchema();
        return self;
    }

    pub fn deinit(self: *Database) void {
        _ = c.sqlite3_close(self.handle);
    }

    fn initSchema(self: *Database) !void {
        const sql = 
            \\CREATE TABLE IF NOT EXISTS agent_chat (
            \\    id INTEGER PRIMARY KEY AUTOINCREMENT,
            \\    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            \\    alias TEXT NOT NULL,
            \\    intent TEXT NOT NULL,
            \\    status TEXT NOT NULL,
            \\    semaphore TEXT,
            \\    notes TEXT
            \\);
        ;
        var error_message: [*c]u8 = null;
        const result_code = c.sqlite3_exec(self.handle, sql, null, null, &error_message);
        if (result_code != c.SQLITE_OK) {
            std.debug.print("SQLite error: {s}\n", .{error_message});
            return error.SqliteSchemaFailed;
        }
    }

    pub fn addAgentChat(self: *Database, alias: []const u8, intent: []const u8, status: []const u8, semaphore: []const u8, notes: []const u8) !void {
        const sql = "INSERT INTO agent_chat (alias, intent, status, semaphore, notes) VALUES (?, ?, ?, ?, ?);";
        var statement: ?*c.sqlite3_stmt = null;

        if (c.sqlite3_prepare_v2(self.handle, sql, -1, &statement, null) != c.SQLITE_OK) {
            return error.SqlitePrepareFailed;
        }
        defer _ = c.sqlite3_finalize(statement);

        _ = c.sqlite3_bind_text(statement, 1, alias.ptr, @intCast(alias.len), null);
        _ = c.sqlite3_bind_text(statement, 2, intent.ptr, @intCast(intent.len), null);
        _ = c.sqlite3_bind_text(statement, 3, status.ptr, @intCast(status.len), null);
        _ = c.sqlite3_bind_text(statement, 4, semaphore.ptr, @intCast(semaphore.len), null);
        _ = c.sqlite3_bind_text(statement, 5, notes.ptr, @intCast(notes.len), null);

        if (c.sqlite3_step(statement) != c.SQLITE_DONE) {
            return error.SqliteExecuteFailed;
        }
    }

    pub fn getRecentChats(self: *Database, limit: usize) ![]AgentChatEntry {
        const sql = "SELECT id, timestamp, alias, intent, status, semaphore, notes FROM agent_chat ORDER BY id DESC LIMIT ?;";
        var statement: ?*c.sqlite3_stmt = null;

        if (c.sqlite3_prepare_v2(self.handle, sql, -1, &statement, null) != c.SQLITE_OK) {
            return error.SqlitePrepareFailed;
        }
        defer _ = c.sqlite3_finalize(statement);

        _ = c.sqlite3_bind_int(statement, 1, @intCast(limit));

        var chats = try std.ArrayList(AgentChatEntry).initCapacity(self.allocator, limit);
        errdefer {
            for (chats.items) |chat| chat.deinit(self.allocator);
            chats.deinit(self.allocator);
        }

        while (c.sqlite3_step(statement) == c.SQLITE_ROW) {
            const id = c.sqlite3_column_int64(statement, 0);
            const timestamp_ptr = c.sqlite3_column_text(statement, 1);
            const alias_ptr = c.sqlite3_column_text(statement, 2);
            const intent_ptr = c.sqlite3_column_text(statement, 3);
            const status_ptr = c.sqlite3_column_text(statement, 4);
            const semaphore_ptr = c.sqlite3_column_text(statement, 5);
            const notes_ptr = c.sqlite3_column_text(statement, 6);

            try chats.append(self.allocator, .{
                .id = id,
                .timestamp = try self.allocator.dupe(u8, std.mem.span(timestamp_ptr)),
                .alias = try self.allocator.dupe(u8, std.mem.span(alias_ptr)),
                .intent = try self.allocator.dupe(u8, std.mem.span(intent_ptr)),
                .status = try self.allocator.dupe(u8, std.mem.span(status_ptr)),
                .semaphore = try self.allocator.dupe(u8, if (semaphore_ptr != null) std.mem.span(semaphore_ptr) else ""),
                .notes = try self.allocator.dupe(u8, if (notes_ptr != null) std.mem.span(notes_ptr) else ""),
            });
        }

        return try chats.toOwnedSlice(self.allocator);
    }

    pub fn searchChats(self: *Database, query: []const u8, limit: usize) ![]AgentChatEntry {
        const sql = 
            \\SELECT id, timestamp, alias, intent, status, semaphore, notes 
            \\FROM agent_chat 
            \\WHERE alias LIKE ? OR intent LIKE ? OR notes LIKE ? 
            \\ORDER BY id DESC LIMIT ?;
        ;
        var statement: ?*c.sqlite3_stmt = null;

        if (c.sqlite3_prepare_v2(self.handle, sql, -1, &statement, null) != c.SQLITE_OK) {
            return error.SqlitePrepareFailed;
        }
        defer _ = c.sqlite3_finalize(statement);

        const wild_query = try std.fmt.allocPrint(self.allocator, "%{s}%", .{query});
        defer self.allocator.free(wild_query);

        _ = c.sqlite3_bind_text(statement, 1, wild_query.ptr, @intCast(wild_query.len), null);
        _ = c.sqlite3_bind_text(statement, 2, wild_query.ptr, @intCast(wild_query.len), null);
        _ = c.sqlite3_bind_text(statement, 3, wild_query.ptr, @intCast(wild_query.len), null);
        _ = c.sqlite3_bind_int(statement, 4, @intCast(limit));

        var chats = try std.ArrayList(AgentChatEntry).initCapacity(self.allocator, limit);
        errdefer {
            for (chats.items) |chat| chat.deinit(self.allocator);
            chats.deinit(self.allocator);
        }

        while (c.sqlite3_step(statement) == c.SQLITE_ROW) {
            const id = c.sqlite3_column_int64(statement, 0);
            const timestamp_ptr = c.sqlite3_column_text(statement, 1);
            const alias_ptr = c.sqlite3_column_text(statement, 2);
            const intent_ptr = c.sqlite3_column_text(statement, 3);
            const status_ptr = c.sqlite3_column_text(statement, 4);
            const semaphore_ptr = c.sqlite3_column_text(statement, 5);
            const notes_ptr = c.sqlite3_column_text(statement, 6);

            try chats.append(self.allocator, .{
                .id = id,
                .timestamp = try self.allocator.dupe(u8, std.mem.span(timestamp_ptr)),
                .alias = try self.allocator.dupe(u8, std.mem.span(alias_ptr)),
                .intent = try self.allocator.dupe(u8, std.mem.span(intent_ptr)),
                .status = try self.allocator.dupe(u8, std.mem.span(status_ptr)),
                .semaphore = try self.allocator.dupe(u8, if (semaphore_ptr != null) std.mem.span(semaphore_ptr) else ""),
                .notes = try self.allocator.dupe(u8, if (notes_ptr != null) std.mem.span(notes_ptr) else ""),
            });
        }

        return try chats.toOwnedSlice(self.allocator);
    }
};
