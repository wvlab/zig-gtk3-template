const std = @import("std");
const c = @import("c.zig");

pub fn g_signal_connect_(instance: c.gpointer, detailed_signal: [*c]const c.gchar, c_handler: c.GCallback, data: c.gpointer) c.gulong {
    var zero: u32 = 0;
    const flags: *c.GConnectFlags = @ptrCast(*c.GConnectFlags, &zero);
    return c.g_signal_connect_data(instance, detailed_signal, c_handler, data, null, flags.*);
}

fn print_hello(widget: *c.GtkWidget, data: c.gpointer) callconv(.C) void {
    _ = .{ widget, data };
    c.g_print("Hello, World!\n");
}

fn activate(app: *c.GtkApplication, data: c.gpointer) callconv(.C) void {
    _ = data;

    const window: *c.GtkWidget = c.gtk_application_window_new(app);
    const win = @ptrCast(*c.GtkWindow, window);
    c.gtk_window_set_title(win, "Window");
    c.gtk_window_set_default_size(win, 200, 200);

    const button: *c.GtkWidget = c.gtk_button_new_with_label("Hello World");
    _ = g_signal_connect_(button, "clicked", @ptrCast(c.GCallback, &print_hello), null);
    c.gtk_container_add(@ptrCast(*c.GtkContainer, window), button);

    c.gtk_widget_show_all(window);
}

pub fn main() !u8 {
    const app = c.gtk_application_new("org.gtk_zig.example", c.G_APPLICATION_FLAGS_NONE);
    defer c.g_object_unref(app);

    _ = g_signal_connect_(app, "activate", @ptrCast(c.GCallback, &activate), null);
    const status = c.g_application_run(@ptrCast(*c.GApplication, app), 0, null);

    return @intCast(u8, status);
}
