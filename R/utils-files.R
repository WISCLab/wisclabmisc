


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
  } else {
    cli::cli_inform("No files were renamed.")
  }

  invisible(rename_plan)
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


# Prepare bullet points for dry-run output
prepare_rename_plan_bullets <- function(rename_plan) {
  changed <- rename_plan$is_changed
  if (!any(changed)) {
    return(c(
      "Rename plan:",
      " " = "No files would be renamed."
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
