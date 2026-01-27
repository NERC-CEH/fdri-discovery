to_entries |
.[] |
if .value then setpath(["value", "raw", .key]; .value) end |
if .value and .value.raw then setpath(["value", "raw"]; .value.raw | tostring) end |
if .value and .value.args then setpath(["value","args"]; .value.args|to_entries|map(if .value|type=="object" then setpath(["value"]; .value|to_entries|map({child_key: .key, value: .value})) else . end)) else . end |
if .value and .value.depends_on then setpath(["value","depends_on"]; .value.depends_on|map({dep_id: .})) else . end |
{"id": .key} + .value