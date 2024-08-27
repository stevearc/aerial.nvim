(message
  (message_name) @name
  (#set! "kind" "Class")) @symbol

(enum
  (enum_name) @name
  (#set! "kind" "Enum")) @symbol

(service
  (service_name) @name
  (#set! "kind" "Interface")) @symbol

(rpc
  (rpc_name) @name
  (#set! "kind" "Method")) @symbol
