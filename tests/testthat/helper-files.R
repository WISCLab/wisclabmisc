


setup_demo_dir_sync_down <- function(root = tempfile("demo-sync-")) {
  from <- fs::path(root, "from")
  to <- fs::path(root, "to")

  fs::dir_create(from)
  fs::dir_create(to)

  fs::dir_create(fs::path(from, "subdir"))
  fs::dir_create(fs::path(to, "subdir"))

  # Same in both: overwrite
  writeLines("same file", fs::path(from, "same.txt"))
  writeLines("same file", fs::path(to, "same.txt"))

  # Same in both: no actoin
  writeLines("same file", fs::path(from, "copied.txt"))
  fs::file_copy(fs::path(from, "copied.txt"), fs::path(to, "copied.txt"))

  # Missing from destination: should copy
  writeLines("copy me", fs::path(from, "copy-me.txt"))

  # Changed in destination: should overwrite
  writeLines("new contents", fs::path(from, "changed.txt"))
  writeLines("old contents", fs::path(to, "changed.txt"))

  # Extra in destination: should skip/delete depending on .delete
  writeLines("extra file", fs::path(to, "extra.txt"))

  # Recursive copy
  writeLines("nested copy me", fs::path(from, "subdir", "nested-copy.txt"))

  # Recursive overwrite
  writeLines("nested new contents", fs::path(from, "subdir", "nested-changed.txt"))
  writeLines("nested old contents", fs::path(to, "subdir", "nested-changed.txt"))

  # Recursive extra
  writeLines("nested extra file", fs::path(to, "subdir", "nested-extra.txt"))

  # Same contents, but newer mtime in source.
  # Under metadata comparison this should overwrite.
  # Under hash comparison this should be unchanged.
  writeLines("unchanged contents", fs::path(to, "newer-but-unchanged.txt"))
  Sys.sleep(1.1)
  writeLines("unchanged contents", fs::path(from, "newer-but-unchanged.txt"))

  # Also test same contents/newer source inside a subdirectory
  writeLines("nested unchanged contents", fs::path(to, "subdir", "nested-newer-but-unchanged.txt"))
  Sys.sleep(1.1)
  writeLines("nested unchanged contents", fs::path(from, "subdir", "nested-newer-but-unchanged.txt"))

  list(
    root = root,
    from = from,
    to = to,
    files_from = fs::dir_ls(from, recurse = TRUE, type = "file"),
    files_to = fs::dir_ls(to, recurse = TRUE, type = "file")
  )
}

