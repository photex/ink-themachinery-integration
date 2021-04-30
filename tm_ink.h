#include <foundation/api_types.h>

#define TM_TT_TYPE__INK_FILE "tm_ink_file"
#define TM_TT_TYPE_HASH__INK_FILE TM_STATIC_HASH("tm_ink_file", 0x24d6800f7ea55535ULL)

enum {
    TM_TT_PROP__INK_FILE__TEXT, // string
};

typedef struct tm_ink_o tm_ink_o;

struct tm_ink_api {
    tm_ink_o* (*open)(struct tm_the_truth_o* tt, tm_tt_id_t id);
    tm_ink_o* (*open_string)(const char* s);
};

#define TM_INK_API_NAME "tm_ink_api"

#define INK_VERSION TM_STATIC_HASH("inkVersion", 0x5c5d8b0ca9c9d407ULL)