# Functions that the reports in analyses/ share. The `site` chunk of each
# report reads this file after it sets `site`, the site folder.

# Save a figure for the paper in `figures/`, which git tracks and the site
# publishes. `draw` is a function that draws the plot. For a ggplot `p`,
# pass function() print(p) as `draw`. The plot goes into a temporary file
# in `figures/`, which gets its name only when the plot succeeds and the
# file ends as a whole PNG file does.
save_png <- function(file, draw, dir = file.path(site, "figures")) {
  if (!is.function(draw)) stop("Pass the plot as a function, such as function() print(p).")
  # A link, or on Windows a junction, can send the figures outside the
  # site, and git commits a symbolic link without the figures.
  figures <- file.path(site, "figures")
  link <- Sys.readlink(figures)
  inside <- file.path(normalizePath(site, winslash = "/"), "figures")
  if ((!is.na(link) && nzchar(link)) || (dir.exists(figures) &&
      tolower(normalizePath(figures, winslash = "/")) != tolower(inside))) {
    stop("`figures` is a link. Replace it with a folder, then render again.")
  }
  if (file.exists(figures) && !dir.exists(figures)) {
    stop("`figures` is a file, not a folder. Rename it, then render again.")
  }
  dir.create(figures, showWarnings = FALSE)
  target <- file.path(dir, file)
  if (dir.exists(target)) stop(target, " is a folder.")
  tmp <- tempfile(".save-", tmpdir = dir, fileext = ".png")
  on.exit(unlink(tmp))
  old <- dev.cur()
  png(tmp, width = 6, height = 4, units = "in", res = 300)
  device <- dev.cur()
  tryCatch(draw(), finally = {
    dev.off(device)
    if (old != 1) dev.set(old)
  })
  # A whole PNG file ends with its IEND chunk. A full disk can cut it short.
  size <- file.size(tmp)
  end <- if (isTRUE(size >= 12)) readBin(tmp, "raw", size)[(size - 11):size] else raw(0)
  if (!identical(end, as.raw(c(0, 0, 0, 0, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82)))) {
    stop("Could not write a whole PNG file for ", target, ".")
  }
  if (!file.rename(tmp, target)) stop("Could not write ", target, ".")
}

# Print the versions of R and of each package that the render uses, with
# the home folder shown as ~, and then the MD5 of this file. The MD5 is
# taken when the `site` chunk reads this file, so a report that later sets
# `site` to a value of its own still prints it.
print_environment <- local({
  # The MD5 of this file, with each CR LF read as LF, so that a copy with
  # Windows line ends gives the same hash. check_supplement() compares it
  # with the file to find reports rendered with other text of it.
  file <- file.path(site, "_scripts", "report.R")
  bytes <- readBin(file, "raw", file.size(file))
  n <- length(bytes)
  if (n > 1) {
    cr <- which(bytes[-n] == as.raw(13) & bytes[-1] == as.raw(10))
    if (length(cr) > 0) bytes <- bytes[-cr]
  }
  tmp <- tempfile()
  writeBin(bytes, tmp)
  md5 <- unname(tools::md5sum(tmp))
  unlink(tmp)
  function() {
    info <- if (requireNamespace("sessioninfo", quietly = TRUE)) {
      sessioninfo::session_info()
    } else {
      utils::sessionInfo()
    }
    # Each spelling of the home folder, longest first.
    windows <- .Platform$OS.type == "windows"
    homes <- Sys.getenv(c("USERPROFILE", "HOME"))
    homes <- c(homes, normalizePath(homes, winslash = "/", mustWork = FALSE))
    if (windows) homes <- c(homes, utils::shortPathName(homes))
    homes <- c(chartr("\\", "/", homes), chartr("/", "\\", homes))
    homes <- unique(sub("[/\\\\]+$", "", homes))
    homes <- homes[!grepl("^([A-Za-z]:)?$", homes)]
    homes <- homes[order(-nchar(homes))]
    # Show the home folder as ~ where a path starts with the whole folder.
    lines <- utils::capture.output(print(info))
    for (home in homes) {
      literal <- gsub("([][{}()|^$.*+?\\\\])", "\\\\\\1", home)
      pattern <- paste0("(?<!\\S)", literal, "(?=[/\\\\]|\\s|$)")
      lines <- gsub(pattern, "~", lines, perl = TRUE, ignore.case = windows)
    }
    writeLines(lines)
    writeLines(paste0("Shared report code: _scripts/report.R, MD5 ", md5))
  }
})
