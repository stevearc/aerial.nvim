; capture each target name from the list
(rule
  (targets
    (_) @name @symbol)
  ; exclude special names that aren't actually targets
  ; https://www.gnu.org/software/make/manual/html_node/Special-Targets.html
  (#not-any-of? @name
    ".PHONY" ".SUFFIXES" ".DEFAULT" ".PRECIOUS" ".INTERMEDIATE" ".NOTINTERMEDIATE" ".SECONDARY"
    ".SECONDEXPANSION" ".DELETE_ON_ERROR" ".IGNORE" ".LOW_RESOLUTION_TIME" ".SILENT"
    ".EXPORT_ALL_VARIABLES" ".NOTPARALLEL" ".ONESHELL" ".POSIX")
  (#set! "kind" "Interface")) @start
