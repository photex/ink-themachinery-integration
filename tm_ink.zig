// zig build-lib tm_ink.zig -I C:/work/themachinery --library c -dynamic

const std = @import("std");

const c = @cImport({
    @cDefine("__ZIG__", {});
    @cInclude("foundation/api_registry.h");
    @cInclude("foundation/log.h");
    @cInclude("foundation/the_truth.h");
    @cInclude("foundation/the_truth_assets.h");
    @cInclude("foundation/plugin_callbacks.h");
    @cInclude("foundation/json.h");
    @cInclude("foundation/config.h");
    @cInclude("foundation/allocator.h");
    @cInclude("foundation/murmurhash64a.inl");
    
    @cInclude("plugins/editor_views/asset_browser.h");
    
    @cInclude("tm_ink.h");
});

var tm_global_api_registry: c.tm_api_registry_api = undefined;

var tm_logger_api: c.tm_logger_api = undefined;
var tm_the_truth_api: c.tm_the_truth_api = undefined;
var tm_json_api: c.tm_json_api = undefined;
var tm_config_api: c.tm_config_api = undefined;
var tm_allocator_api: c.tm_allocator_api = undefined;

const ink_template = "Test ink template";

var plugin_tick_i: c.tm_plugin_tick_i = undefined;
var asset_browser__create_asset__ink_file_i: c.tm_asset_browser_create_asset_i = undefined;

fn initVars() void {
    std.mem.set(u8, std.mem.asBytes(&plugin_tick_i), 0);
    plugin_tick_i.tick = tick;

    std.mem.set(u8, std.mem.asBytes(&asset_browser__create_asset__ink_file_i), 0);
    asset_browser__create_asset__ink_file_i.menu_name = "New Ink File";
    asset_browser__create_asset__ink_file_i.asset_name = "Ink File";
    asset_browser__create_asset__ink_file_i.create = asset_browser__create_asset__ink_file;
}

fn tick(inst: ?*c.tm_plugin_o, dt: f32) callconv(.C) void {
    parse("");
}

fn asset_browser__create_asset__ink_file(inst: ?*c.tm_asset_browser_create_asset_o, tt: ?*c.tm_the_truth_o, undo_scope: c.tm_tt_undo_scope_t) callconv(.C) c.tm_tt_id_t
{
    const id = tm_the_truth_api.create_object_of_hash.?(tt, c.TM_TT_TYPE_HASH__INK_FILE, undo_scope);
    const wr = tm_the_truth_api.write.?(tt, id);
    tm_the_truth_api.set_string.?(tt, wr, c.TM_TT_PROP__INK_FILE__TEXT, "Test Text");
    tm_the_truth_api.commit.?(tt, wr, undo_scope);
    return id;
}

fn truth__create_types(tt: ?*c.tm_the_truth_o) callconv(.C) void {
    var property : c.tm_the_truth_property_definition_t = undefined;
    std.mem.set(u8, std.mem.asBytes(&property), 0);
    property.name = "text";
    property.type =  c.TM_THE_TRUTH_PROPERTY_TYPE_STRING;

    const ink_file = tm_the_truth_api.create_object_type.?(tt, c.TM_TT_TYPE__INK_FILE, &property, 1);
    tm_the_truth_api.set_aspect.?(tt, ink_file, c.TM_TT_ASPECT__FILE_EXTENSION, "ink");

    // tm_the_truth_api->set_aspect(tt, c_file, TM_TT_ASPECT__PROPERTIES, &properties__c_file_i);
    // tm_the_truth_api->set_aspect(tt, c_file, TM_TT_ASPECT__ASSET_OPEN, &asset__open__c_file_i);
}

fn parse(str: [*:0]const u8) void {
    var allocator = tm_allocator_api.system;
    var config = tm_config_api.create.?(allocator);
    
    var err: [c.TM_JSON_ERROR_STRING_LENGTH+1]u8 = undefined;
    const opt = @intToEnum(c.enum_tm_json_parse_ext, 0);

    _ = tm_json_api.parse.?("{\"inkVersion\": 20}", config, opt, &err);
    const root = config.*.root.?(config.*.inst);
    const version_o = config.*.object_get.?(config.*.inst, root, c.INK_VERSION);
    const version = config.*.to_number.?(config.*.inst, version_o);
      _ = tm_logger_api.printf.?(c.tm_log_type.TM_LOG_TYPE_INFO, "Ink version: %f", version);
}

export fn tm_load_plugin(reg: *c.tm_api_registry_api, load: bool) void {
    tm_global_api_registry = reg.*;

    tm_logger_api = @ptrCast([*c]c.tm_logger_api, @alignCast(8, reg.*.get.?(c.TM_LOGGER_API_NAME))).*;
    tm_the_truth_api = @ptrCast([*c]c.tm_the_truth_api, @alignCast(8, reg.*.get.?(c.TM_THE_TRUTH_API_NAME))).*;
    tm_json_api = @ptrCast([*c]c.tm_json_api, @alignCast(8, reg.*.get.?(c.TM_JSON_API_NAME))).*;
    tm_config_api = @ptrCast([*c]c.tm_config_api, @alignCast(8, reg.*.get.?(c.TM_CONFIG_API_NAME))).*;
    tm_allocator_api = @ptrCast([*c]c.tm_allocator_api, @alignCast(8, reg.*.get.?(c.TM_ALLOCATOR_API_NAME))).*;

    initVars();

    if (load) {
        _ = tm_logger_api.printf.?(c.tm_log_type.TM_LOG_TYPE_INFO, "Ink plugin %s.\n", "loaded");

        reg.add_implementation.?(c.TM_THE_TRUTH_CREATE_TYPES_INTERFACE_NAME, truth__create_types);
        reg.add_implementation.?(c.TM_PLUGIN_TICK_INTERFACE_NAME, &plugin_tick_i);
        reg.add_implementation.?(c.TM_ASSET_BROWSER_CREATE_ASSET_INTERFACE_NAME, &asset_browser__create_asset__ink_file_i);
    } else {
        reg.remove_implementation.?(c.TM_THE_TRUTH_CREATE_TYPES_INTERFACE_NAME, truth__create_types);
        reg.remove_implementation.?(c.TM_PLUGIN_TICK_INTERFACE_NAME, &plugin_tick_i);
        reg.remove_implementation.?(c.TM_ASSET_BROWSER_CREATE_ASSET_INTERFACE_NAME, &asset_browser__create_asset__ink_file_i);
    }
}