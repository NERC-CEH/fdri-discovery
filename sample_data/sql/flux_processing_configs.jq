.processing_configs[] 
  | . += {"depends_on": .params.dep_ts, "raw": . | tostring} 
  | . += {"param_entries": .params | to_entries 
    | map(if((.value | type == "array") and (.value | any(type == "object"))) then {key: .key, structured_value: (.value | map(to_entries | map({child_key: .key, value: .value})))} else {key: .key, value: .value} end)
         }
  | del(.params)
  | del(..|nulls)