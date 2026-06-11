# Sync one directory down into another

`dir_sync_down()` syncs the files in one directory into another
directory. Files that are present in `path` but missing from `path_new`
are copied. Files that are present in both directories but differ are
overwritten. Files that are present in `path_new` but absent from `path`
are ignored unless `.delete = TRUE`.

## Usage

``` r
dir_sync_down(
  path,
  path_new,
  .dry_run = TRUE,
  .delete = FALSE,
  .compare = c("metadata", "md5", "xxhash")
)
```

## Arguments

- path:

  Source directory.

- path_new:

  Destination directory.

- .dry_run:

  Whether to preview the sync plan without changing files. Defaults to
  `TRUE`.

- .delete:

  Whether to delete files in `path_new` that are absent from `path`.
  Defaults to `FALSE`, so extra destination files are ignored unless
  deletion is explicitly enabled.

- .compare:

  Method used to determine whether files differ. `"metadata"` compares
  file size and modification time. `"md5"` compares file contents using
  [`tools::md5sum()`](https://rdrr.io/r/tools/md5sum.html). `"xxhash"`
  compares file contents using
  [`xxhashlite::xxhash_file()`](https://rdrr.io/pkg/xxhashlite/man/xxhash_file.html),
  if the `xxhashlite` package is installed.

## Value

A data frame describing the directory sync plan, invisibly. The plan
includes the relative file path, the planned `action`, the `reason` for
the action, source and destination file metadata, and the source and
destination paths used for copying.

## Details

By default, this function performs a dry run: it prints a summary of the
sync plan and returns the plan invisibly without changing any files. Set
`.dry_run = FALSE` to copy, overwrite, or delete files.

The possible values of `action` are:

- `"copy"`: copy a file from `path` because it is missing from
  `path_new`;

- `"overwrite"`: overwrite a destination file because the source and
  destination files differ;

- `"delete"`: delete an extra destination file, when `.delete = TRUE`;

- `"ignore"`: leave an extra destination file unchanged, when
  `.delete = FALSE`;

- `"none"`: leave a file unchanged.

With `.compare = "metadata"`, files are treated as different when their
size or modification time differs. With `.compare = "md5"` or
`.compare = "xxhash"`, files that exist on both sides are compared by
content hash instead. Under hash comparison, files with the same
contents are treated as unchanged even if their modification times
differ.

## Examples

``` r
dir_from <- tempfile()
dir_to <- tempfile()

fs::dir_create(dir_from)
fs::dir_create(dir_to)

writeLines("same", fs::path(dir_from, "same.txt"))
writeLines("same", fs::path(dir_to, "same.txt"))

writeLines("copy me", fs::path(dir_from, "new.txt"))

writeLines("new contents", fs::path(dir_from, "changed.txt"))
writeLines("old contents", fs::path(dir_to, "changed.txt"))

writeLines("extra", fs::path(dir_to, "extra.txt"))

# Preview the sync plan without changing files
plan <- dir_sync_down(dir_from, dir_to)
#> Dry run: 🔃 Would update /tmp/Rtmp3y6IgG/file1cd37560dfb0
#>   1 new file (copy), 2 out-of-sync files (overwrite), 1 extra file (ignore)

# Actually copy and overwrite files, but keep extra destination files
dir_sync_down(dir_from, dir_to, .dry_run = FALSE)
#> 🔃 Updating /tmp/Rtmp3y6IgG/file1cd37560dfb0
#>   1 new file (copy), 2 out-of-sync files (overwrite), 1 extra file (ignore)

# Also delete extra destination files
dir_sync_down(dir_from, dir_to, .dry_run = FALSE, .delete = TRUE)
#> 🔃 Updating /tmp/Rtmp3y6IgG/file1cd37560dfb0
#>   0 new files (copy), 3 out-of-sync files (overwrite), 1 extra file (delete)
```
