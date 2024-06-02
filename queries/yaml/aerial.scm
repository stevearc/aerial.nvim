(block_mapping_pair
  key: (flow_node) @name
  value: (block_node
    (block_mapping) @symbol)
  (#set! "kind" "Class")) @start

(block_mapping_pair
  key: (flow_node) @name
  value: (block_node
    (block_sequence) @symbol)
  (#set! "kind" "Enum")) @start
