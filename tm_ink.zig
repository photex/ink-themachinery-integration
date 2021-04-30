// zig build-lib tm_ink.zig -I C:/work/themachinery --library c -dynamic

const c = @cImport({
    @cDefine("__ZIG__", {});
    @cInclude("foundation/api_registry.h");
    @cInclude("foundation/log.h");
    @cInclude("foundation/the_truth.h");
    @cInclude("foundation/plugin_callbacks.h");
});

var tm_global_api_registry: c.tm_api_registry_api = undefined;

var tm_logger_api: c.tm_logger_api = undefined;
var tm_the_truth_api: c.tm_the_truth_api = undefined;

var plugin_tick_i: c.tm_plugin_tick_i = undefined;

fn initPluginTick() void {
    plugin_tick_i.tick = tick;
}

fn tick(inst: ?*c.tm_plugin_o, dt: f32) callconv(.C) void {
    _ = tm_logger_api.printf.?(c.tm_log_type.TM_LOG_TYPE_INFO, "Plugin tick!");
}

fn truth__create_types(tt: ?*c.tm_the_truth_o) callconv(.C) void {
}

export fn tm_load_plugin(reg: *c.tm_api_registry_api, load: bool) void {
    tm_global_api_registry = reg.*;

    tm_logger_api = @ptrCast([*c]c.tm_logger_api, @alignCast(8, reg.*.get.?(c.TM_LOGGER_API_NAME))).*;
    tm_the_truth_api = @ptrCast([*c]c.tm_the_truth_api, @alignCast(8, reg.*.get.?(c.TM_THE_TRUTH_API_NAME))).*;

    _ = tm_logger_api.printf.?(c.tm_log_type.TM_LOG_TYPE_INFO, "Ink plugin %s.\n", "loaded");

    initPluginTick();

    if (load) {
        // reg.add_implementation.?(c.TM_THE_TRUTH_CREATE_TYPES_INTERFACE_NAME, &create_truth_types);
        reg.add_implementation.?(c.TM_PLUGIN_TICK_INTERFACE_NAME, &plugin_tick_i);
    } else {
        reg.remove_implementation.?(c.TM_PLUGIN_TICK_INTERFACE_NAME, &plugin_tick_i);
    }
}