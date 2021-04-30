// zig build-lib tm_ink.zig -I C:/work/themachinery --library c -dynamic

const c = @cImport({
    @cInclude("foundation/api_registry.h");
    @cInclude("foundation/log.h");
});

var tm_logger_api: c.tm_logger_api = undefined;

export fn tm_load_plugin(reg: *c.tm_api_registry_api, load: bool) void {
    tm_logger_api = @ptrCast([*c]c.tm_logger_api, @alignCast(8, reg.*.get.?(c.TM_LOGGER_API_NAME))).*;
    _ = tm_logger_api.printf.?(c.tm_log_type.TM_LOG_TYPE_INFO, "Ink plugin %s.\n", "loaded");
}