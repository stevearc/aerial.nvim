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

; "array element" with a "name:" key
; ansible play/task names, etc
; github workflow/actions jobs/steps, etc
(block_sequence_item
  (block_node
    (block_mapping
      (block_mapping_pair
        key: (flow_node
          (plain_scalar
            (string_scalar) @_key))
        value: (flow_node
          (plain_scalar
            (string_scalar) @name)))))
  (#eq? @_key "name")
  (#set! "kind" "Module")) @symbol
