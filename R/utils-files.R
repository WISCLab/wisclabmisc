


#' Rename file basenames using functions
#'
#' `file_replace_name()` uses [stringr::str_replace()] to rename files.
#' `file_rename_with()` allows you to rename files with a generic
#' string-transforming function.
#'
#' @export
#' @param path vector of paths for files to rename
#' @param pattern,replacement arguments forwarded to [stringr::str_replace()]
#' @param .fn function to apply to file basenames
#' @param ... arguments passed onto `.fn`
#' @param .dry_run when `FALSE`, files are renamed. When `TRUE` (the default),
#' no files are renamed but the rename plan is printed.
#' @param .overwrite Whether to overwrite files. Defaults to `FALSE` so that
#' overwriting files is opt-in.
#' @return a dataframe describing the file-renaming plan. Files that would
#'   overwrite an existing file are skipped unless `.overwrite = TRUE`. This
#'   function throws an error if a name collision is detected, where two files
#'   are both renamed into the same target path.
#' @rdname file_rename_with
#' @details Only the basename of the file (returned by [basename()])
#' undergoes string replacement.
#'
#' @examples
#' # With .dry_run = TRUE, we can make up some file paths.
#' dir <- "//some-fake-location/"
#' path <- file.path(
#'   dir,
#'   c("report_1.csv", "report_2.csv", "report-1.csv", "skipped.csv")
#' )
#'
#' updated <- file_replace_name(path, "report_", "report-", .dry_run = TRUE)
#'
#' # Collisions are detected
#' updated <- file_replace_name(path, "report_\\d", "report-1", .dry_run = TRUE)
#'
#' # Doing nothing
#' updated <- file_rename_with(path, identity, .dry_run = TRUE)
file_replace_name <- function(
    path,
    pattern,
    replacement,
    .dry_run = TRUE,
    .overwrite = FALSE
) {
  file_rename_with(
    path = path,
    .fn = stringr::str_replace,
    pattern,
    replacement,
    .dry_run = .dry_run,
    .overwrite = .overwrite
  )
}


#' @rdname file_rename_with
#' @export
file_rename_with <- function(
    path,
    .fn,
    ...,
    .dry_run = TRUE,
    .overwrite = FALSE
) {
  path_old <- unique(fs::path_norm(path))
  basename_old <- basename(path_old)
  basename_new <- .fn(basename_old, ...)
  path_new <- fs::path(fs::path_dir(path_old), basename_new)

  file_rename_impl(path_old, path_new, .dry_run, .overwrite)
}


file_rename_impl <- function(path, path_new, .dry_run, .overwrite) {
  rename_plan <- prepare_file_rename_plan(path, path_new, .overwrite)
  msg <- prepare_file_rename_message(rename_plan, .dry_run, .overwrite)
  switch(
    msg$cli_f,
    abort = cli::cli_abort(msg$message_proc),
    warn = cli::cli_warn(msg$message_proc),
    inform = cli::cli_inform(msg$message_proc)
  )

  if (.dry_run) return(invisible(rename_plan))

  to_move <- rename_plan$action %in% c("rename", "overwrite")
  if (any(to_move)) {
    fs::file_move(
      rename_plan[to_move, "path"],
      rename_plan[to_move, "path_new"]
    )
  }

  invisible(rename_plan)
}


prepare_file_rename_plan <- function(path, path_new, .overwrite) {
  is_duplicated <- function(x) duplicated(x) | duplicated(x, fromLast = TRUE)

  is_changed <- path != path_new
  is_overwrite <- is_changed & fs::file_exists(path_new)
  is_unchanged <- !is_changed & !is_duplicated(path_new)

  # A chain occurs when a new name is one of the paths set to change
  is_chained <- is_changed & path_new %in% path[is_changed]

  # A collision occurs when multiple source files rename to the same target
  is_changed_with_collision <- is_duplicated(path_new[is_changed])
  has_name_collision <- rep(FALSE, length(is_changed))
  has_name_collision[is_changed] <- is_changed_with_collision

  action <- rep("none", length(is_changed))
  action[is_changed] <- "rename"
  action[is_overwrite & !.overwrite] <- "skip"
  action[is_overwrite & .overwrite] <- "overwrite"
  action[is_chained] <- "fail"
  action[has_name_collision] <- "fail"

  reason <- rep("unchanged", length(is_changed))
  reason[is_changed] <- "renamed"
  reason[is_overwrite & !.overwrite] <- "overwrite disabled"
  reason[is_overwrite & .overwrite] <- "overwrite"
  reason[is_chained] <- "chained rename"
  reason[has_name_collision] <- "name collision"

  data.frame(
    path = path,
    path_new = path_new,
    action = action,
    reason = reason,
    is_changed = is_changed,
    has_name_collision = has_name_collision,
    is_overwrite = is_overwrite,
    is_unchanged = is_unchanged,
    is_chained = is_chained
  )
}


prepare_file_rename_message <- function(rename_plan, .dry_run, .overwrite) {
  cli_f <- "inform"
  heading <- character(0)
  failed <- FALSE
  n_skip <- sum(rename_plan$action == "skip")
  n_collisions <- sum(rename_plan$has_name_collision)

  if (any(rename_plan$action == "fail")) {
    failed <- TRUE

    heading <- "Cannot safely rename files"
    if (any(rename_plan$has_name_collision)) {
      heading <- c(
        heading,
        "x" = "{n_collisions} file{?s} have naming collisions",
        "*" = "Ensure that files do not rename to the same destination"
      )
    }
    if (any(rename_plan$is_chained)) {
      chain_bullets <- format_rename_chains(rename_plan)
      heading <- c(
        heading,
        "x" = "Detected chained renames:",
        chain_bullets,
        "*" = "Rename files in separate steps to avoid order-dependent file renames."
      )
    }
  }

  if (any(rename_plan$is_overwrite) && !.overwrite && !failed) {
    heading <- c(
      heading,
      "!" = "Skipping {n_skip} file{?s} that would overwrite existing files.",
      "i" = "Set {.code .overwrite = TRUE} to apply these changes."
    )
  }

  if (length(heading)) heading <- c(heading, "")

  message <- c(heading, prepare_rename_plan_bullets(rename_plan))

  if (failed && !.dry_run) cli_f <- "abort"
  if (failed && .dry_run) cli_f <- "warn"

  message_proc <- message
  for (i in seq_along(message)) {
    message_proc[i] <- cli::format_inline(message[i])
  }
  list(cli_f = cli_f, message_proc = message_proc)
}


prepare_rename_plan_bullets <- function(rename_plan) {
  changed <- rename_plan$is_changed
  if (!any(changed)) {
    return(c(
      "Rename plan:",
      " " = "No files need to be renamed."
    ))
  }

  changes <- rename_plan |>
    split(~path_new) |>
    lapply(function(df) {
      if (all(df$is_unchanged)) return(character(0))
      old_names <- basename(df[df$is_changed, "path"])

      if (length(old_names) > 1) {
        old_part <- paste0(old_names, collapse = ", ") |> sprintf(fmt = "(%s)")
      } else {
        old_part <- old_names
      }

      note <- ""
      bullet <- " "
      if (any(df$action == "fail") && any(df$reason == "name collision")) {
        note <- " {.emph (naming collision)}"
        bullet <- "x"
      } else if (any(df$action == "fail") && any(df$reason == "chained rename")) {
        note <- " {.emph (chained rename)}"
        bullet <- "x"
      } else if (any(df$action == "skip")) {
        note <- " {.emph (skipped: overwrites not allowed)}"
        bullet <- "!"
      } else if (any(df$action == "overwrite")) {
        note <- " {.emph (overwrites an existing file)}"
        bullet <- "!"
      }

      new_part <- unique(basename(df$path_new))
      change <- sprintf("%s -> %s%s", old_part, new_part, note)
      names(change) <- bullet
      change
    }) |>
    unname() |>
    unlist()


  c("Rename plan:", changes)
}

# ChatGPT assisted on the chain detection
find_rename_chains <- function(rename_plan) {
  changed <- rename_plan[rename_plan$is_changed, , drop = FALSE]
  from <- as.character(changed$path)
  to <- as.character(changed$path_new)
  names(to) <- from
  is_linked_source <- from %in% to
  roots <- from[!is_linked_source & to %in% from]

  # If there are cycles, there may be no roots.
  cycle_starts <- from[to %in% from & is_linked_source]
  starts <- c(roots, cycle_starts)

  chains <- list()
  consumed <- character(0)

  for (start in starts) {
    if (start %in% consumed) next

    chain <- start
    seen <- character(0)
    current <- start

    while (current %in% names(to)) {
      if (current %in% seen) {
        chain <- c(chain, to[[current]])
        break
      }

      seen <- c(seen, current)
      consumed <- c(consumed, current)

      next_path <- unname(to[[current]])
      chain <- c(chain, next_path)
      current <- next_path

      if (!(current %in% names(to))) {
        break
      }
    }

    if (length(chain) > 2 || chain[2] %in% from) {
      chains[[length(chains) + 1]] <- chain
    }
  }

  chains
}

# ChatGPT assisted on the chain detection
format_rename_chains <- function(rename_plan) {
  chains <- find_rename_chains(rename_plan)

  if (!length(chains)) {
    return(character(0))
  }

  bullets <- vapply(
    chains,
    function(x) paste(basename(x), collapse = " -> "),
    FUN.VALUE = character(1)
  )

  names(bullets) <- " "
  bullets
}





#' Sync one directory down into another
#'
#' `dir_sync_down()` syncs the files in one directory into another directory.
#' Files that are present in `path` but missing from `path_new` are copied.
#' Files that are present in both directories but differ are overwritten.
#' Files that are present in `path_new` but absent from `path` are ignored
#' unless `.delete = TRUE`.
#'
#' By default, this function performs a dry run: it prints a summary of the
#' sync plan and returns the plan invisibly without changing any files. Set
#' `.dry_run = FALSE` to copy, overwrite, or delete files.
#'
#' @param path Source directory.
#' @param path_new Destination directory.
#' @param .dry_run Whether to preview the sync plan without changing files.
#'   Defaults to `TRUE`.
#' @param .delete Whether to delete files in `path_new` that are absent from
#'   `path`. Defaults to `FALSE`, so extra destination files are ignored unless
#'   deletion is explicitly enabled.
#' @param .compare Method used to determine whether files differ. `"metadata"`
#'   compares file size and modification time. `"md5"` compares file contents
#'   using [tools::md5sum()]. `"xxhash"` compares file contents using
#'   `xxhashlite::xxhash_file()`, if the `xxhashlite` package is installed.
#'
#' @return A data frame describing the directory sync plan, invisibly. The plan
#'   includes the relative file path, the planned `action`, the `reason` for the
#'   action, source and destination file metadata, and the source and destination
#'   paths used for copying.
#'
#' @details The possible values of `action` are:
#'   * `"copy"`: copy a file from `path` because it is missing from `path_new`;
#'   * `"overwrite"`: overwrite a destination file because the source and
#'     destination files differ;
#'   * `"delete"`: delete an extra destination file, when `.delete = TRUE`;
#'   * `"ignore"`: leave an extra destination file unchanged, when
#'     `.delete = FALSE`;
#'   * `"none"`: leave a file unchanged.
#'
#'   With `.compare = "metadata"`, files are treated as different when their
#'   size or modification time differs. With `.compare = "md5"` or
#'   `.compare = "xxhash"`, files that exist on both sides are compared by
#'   content hash instead. Under hash comparison, files with the same contents
#'   are treated as unchanged even if their modification times differ.
#'
#' @examples
#' dir_from <- tempfile()
#' dir_to <- tempfile()
#'
#' fs::dir_create(dir_from)
#' fs::dir_create(dir_to)
#'
#' writeLines("same", fs::path(dir_from, "same.txt"))
#' writeLines("same", fs::path(dir_to, "same.txt"))
#'
#' writeLines("copy me", fs::path(dir_from, "new.txt"))
#'
#' writeLines("new contents", fs::path(dir_from, "changed.txt"))
#' writeLines("old contents", fs::path(dir_to, "changed.txt"))
#'
#' writeLines("extra", fs::path(dir_to, "extra.txt"))
#'
#' # Preview the sync plan without changing files
#' plan <- dir_sync_down(dir_from, dir_to)
#'
#' # Actually copy and overwrite files, but keep extra destination files
#' dir_sync_down(dir_from, dir_to, .dry_run = FALSE)
#'
#' # Also delete extra destination files
#' dir_sync_down(dir_from, dir_to, .dry_run = FALSE, .delete = TRUE)
#'
#' @export
dir_sync_down <- function(
    path,
    path_new,
    .dry_run = TRUE,
    .delete = FALSE,
    .compare = c("metadata", "md5", "xxhash")
) {
  .compare <- rlang::arg_match(.compare)
  path <- fs::path_abs(path)
  path_new <- fs::path_abs(path_new)

  if (!fs::dir_exists(path)) {
    cli::cli_abort("{.arg path} must be an existing directory.")
  }
  if (!.dry_run) fs::dir_create(path_new)

  sync_plan <- prepare_dir_sync_plan(
    path = path,
    path_new = path_new,
    .delete = .delete,
    .compare = .compare
  )

  sync_newer <- sync_plan |>
    dplyr::filter(.data$action %in% c("copy", "overwrite"))
  sync_extra <- sync_plan |>
    dplyr::filter(.data$action %in% c("ignore", "delete"))

  if (nrow(sync_newer) == 0 && nrow(sync_extra) == 0) {
    cli::cli_inform(
      c("v" = "Skipping {.file {path_new}}")
    )
  } else {
    n_c <- sum(sync_newer[["action"]] == "copy")
    n_w <- sum(sync_newer[["action"]] == "overwrite")
    n_x <- nrow(sync_extra)
    action_x <- if (.delete) "delete" else "ignore"

    main_action <- if (.dry_run) {
      "Dry run: \U0001F503 Would update {.file {path_new}}"
    } else {
      "\U0001F503 Updating {.file {path_new}}"
    }
    cli::cli_inform(
      c(
        main_action,
        " " = "{n_c} new file{?s} (copy), {n_w} out-of-sync file{?s} (overwrite), {n_x} extra file{?s} ({action_x})"
      )
    )

    if (.dry_run) {
      return(invisible(sync_plan))
    }

    if (nrow(sync_extra) && .delete) {
      fs::file_delete(sync_extra$copy_to)
    }
    if (nrow(sync_newer)) {
      files_from <- sync_newer$copy_from
      files_to <- sync_newer$copy_to
      fs::dir_create(fs::path_dir(files_to))
      fs::file_copy(files_from, files_to, overwrite = TRUE)
    }
  }

  invisible(sync_plan)
}

prepare_dir_sync_plan <- function(
    path,
    path_new,
    .delete = FALSE,
    .compare = c("metadata", "md5", "xxhash")
) {
  .compare <- rlang::arg_match(.compare)

  info_from <- collect_dir_file_info(path, side = "from")
  info_to <- collect_dir_file_info(path_new, side = "to")

  plan <- info_from |>
    dplyr::full_join(info_to, by = "path_rel")

  # i.e., extra files
  from_missing <- is.na(plan$path_from)
  # i.e., missing files
  to_missing <- is.na(plan$path_to)

  size_differs <- !from_missing & !to_missing & plan$size_from != plan$size_to
  mtime_differs <- !from_missing & !to_missing & plan$mtime_from != plan$mtime_to

  plan$action <- "none"
  plan$reason <- "unchanged"

  plan$action[to_missing] <- "copy"
  plan$reason[to_missing] <- "missing"

  plan$action[size_differs | mtime_differs] <- "overwrite"
  plan$reason[size_differs] <- "size differs"
  plan$reason[!size_differs & mtime_differs] <- "mtime differs"

  plan$action[from_missing] <- if (.delete) "delete" else "ignore"
  plan$reason[from_missing] <- if (.delete) "extra file" else "delete disabled"

  # `path_from`, `path_to` are existing files.
  # `copy_*` columns are intended for the `file_copy()` command. they include new
  # files missing in `path_to`
  plan <- compare_file_hashes_in_sync_plan(plan, .compare = .compare)
  plan$copy_from <- fs::path(path, plan$path_rel)
  plan$copy_to <- fs::path(path_new, plan$path_rel)

  plan[, c(
    "path_rel",
    "action",
    "reason",
    "size_from",
    "size_to",
    "mtime_from",
    "mtime_to",
    "path_from",
    "path_to",
    "copy_from",
    "copy_to"
  )]
}


collect_dir_file_info <- function(path, side = c("from", "to")) {
  side <- rlang::arg_match(side)

  if (!fs::dir_exists(path)) {
    out <- tibble::tibble(
      path_rel = fs::path(),
      path = fs::path(),
      size = numeric(),
      mtime = as.POSIXct(character())
    )
  } else {
    info <- fs::dir_info(path, recurse = TRUE, type = "file")
    out <- tibble::tibble(
      path_rel = fs::path_rel(info$path, start = path),
      path = fs::path(as.character(info$path)),
      size = as.numeric(info$size),
      mtime = info$modification_time
    )
  }
  s <- c("path", "size", "mtime")
  names(out)[names(out) %in% s] <- paste0(s, "_", side)

  out
}


compare_file_hashes_in_sync_plan <- function(
    plan,
    .compare = c("metadata", "md5", "xxhash")
) {
  .compare <- rlang::arg_match(.compare)
  if (.compare == "metadata") return(plan)

  comparable <- !is.na(plan$path_from) & !is.na(plan$path_to)
  if (!any(comparable)) return(plan)

  hash_from <- file_hash(plan$path_from[comparable], .compare = .compare)
  hash_to <- file_hash(plan$path_to[comparable], .compare = .compare)
  hash_differs <- hash_from != hash_to

  rows <- which(comparable)

  plan$action[rows[hash_differs]] <- "overwrite"
  plan$reason[rows[hash_differs]] <- "hash differs"

  plan$action[rows[!hash_differs]] <- "none"
  plan$reason[rows[!hash_differs]] <- "unchanged"

  plan
}

file_hash <- function(path, .compare = c("md5", "xxhash")) {
  .compare <- rlang::arg_match(.compare)

  if (.compare == "xxhash") {
    rlang::check_installed(
      "xxhashlite",
      reason = "to use `.compare = \"xxhash\"`"
    )
  }

  switch(
    .compare,
    md5 = unname(tools::md5sum(path)),
    xxhash = xxhashlite::xxhash_file(path, algo = "xxh64")
  )
}
