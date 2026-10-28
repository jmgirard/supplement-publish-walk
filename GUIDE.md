# Guide for the site's authors

This guide shows how to add reports and data, render the site, check it,
and make a release. The template's `_README.md` is the page for the
site's readers. The first render renames it to `README.md` unless the
folder already had a `README.md`. It gives the paper's citation, the site
address, and the contents of this folder. The "Reference" part at the end
holds the rules for some edge cases.

## Reports

The home page lists each `.qmd` file in `analyses/` in a table, with the
`title` and the `description` from the front matter of the file. A report
with no `description` shows the start of its text there. The title links
to the report's page. The table lists the reports that have an `order` in
their front matter first, by that number, and the others after them by
title. The example report has `order: 1`. To add a report, put its `.qmd`
file in `analyses/` with a `title` and a `description`. Give it an `order`
higher than every other report's. If no other report has an `order`, give
it none, and the table lists the reports by title. Then add a link to it under `Analyses` in
the navbar in `_quarto.yml`. To change the order of the table, edit the
`order` values. Then render each changed report by name, and then the
whole site.

The supplement R package does these steps for you. Run these in R from
this folder:

```r
supplement::add_report("models", "Model Comparison", "Fits and compares the models.")
supplement::add_data("path/to/scores.csv", "Scores of each participant")
```

`add_report()` writes `analyses/models.qmd` and adds it to the Analyses
menu. It gives the report the next `order`. The home page lists the
reports with an `order` first, by that number, and the others after them by
title. So it lists the reports in the order of the menu while every report
has an `order` and the menu follows those values. The new report ends with the "Computing environment" section below.
`add_data()` copies the file into `data/` and adds it to the `data` list in
`_supplement.yml`.

### Shared report code

`_scripts/report.R` holds the functions that the reports share:
`save_png()` (see "Paper figures") and `print_environment()` (see
"Computing environment"). Each report reads the file in its `site` chunk,
after the lines that set `site`:

```r
source(file.path(site, "_scripts", "report.R"), local = TRUE)
```

A site made before this file existed does not have it. `add_report()`
copies the template's file into such a site, and never replaces a file
that is there. Commit `_scripts/report.R` with the first report that
uses it, because a clone without the file cannot render the report. To
copy it yourself, R prints the path of the template's copy:

```r
system.file("template", "_scripts", "report.R", package = "supplement")
```

The example report calls `save_png()` and `print_environment()`, and each
report from `add_report()` calls `print_environment()`. If you edit
`_scripts/report.R`, keep both functions in it, because a report that
calls a missing function fails to render.

`check_supplement()` compares the text of each report with the hash in its
stored output. If a report names `_scripts/report.R` and the file is
missing, it gives a row. `print_environment()` also prints the MD5 of
`_scripts/report.R`. `check_supplement()` gives a row for each report
whose stored output gives another MD5 than the file has now. A report
rendered before the site had this version of the file gives no MD5, so it
gets no row. After you change
`_scripts/report.R`, render each report by name, for
example `quarto render analyses/models.qmd`. Then render the whole site
with `quarto render`, and commit the reports with `_freeze/`, `docs/`, and
`figures/`. In the R console, `supplement::render_supplement(c("models",
"checks"))` does these renders for the reports that you name.

### Computing environment

The example report and each report that `add_report()` writes end with a
"Computing environment" section. It shows the version of R and of each
package that the report's last render used. A full render reuses the
stored output in `_freeze/`. So when `_freeze/` holds output for a report,
its page keeps the versions of the render that made its results.

The section calls `print_environment()` from `_scripts/report.R`. If the
sessioninfo package is installed, the function prints
`sessioninfo::session_info()`. Otherwise it prints `utils::sessionInfo()`,
which comes with R. The output also shows your operating system, your time
zone, and some folders on your computer: the R library folders, Pandoc,
and Quarto with sessioninfo, and the BLAS and LAPACK files without it. The
function shows your home folder as `~`, in each spelling that R gives for
it. Folders outside your home folder show in full, so read the output
before you publish it. The last line gives the MD5 of `_scripts/report.R`,
with each CR LF read as LF. `check_supplement()` compares it with the file
(see "Shared report code").

To add the section to an older report, follow these steps. If the site
has no `_scripts/report.R`, copy it in as "Shared report code" says. Then
add the `source()` line from that section to the report's `site` chunk.
Then paste the section of `analyses/example.qmd`, from its
`## Computing environment` heading to the end of the file, at the end of
the report. If you removed the example, R prints the path of the
template's copy:

```r
system.file("template", "analyses", "example.qmd", package = "supplement")
```

Then render the report by name, for example
`quarto render analyses/models.qmd`. Then render the whole site with
`quarto render`, and commit the report with `_freeze/`, `docs/`, and
`figures/`. In the R console, `supplement::render_supplement("models")`
does both renders. If you copied `_scripts/report.R` in, commit it too. A full render
alone reuses the old stored output, so it does not show the new section. An older report whose section holds the
full code, and no `print_environment()` call, still renders as it is.

## Paper facts in `_supplement.yml`

`_supplement.yml` holds the facts about the paper under one `supplement`
key: the paper title, the citation, a preprint link, a contact line, the
licenses, the authors, the Zenodo DOIs and archive link, and the data
files. It also holds the site version. `_quarto.yml` loads the file with `metadata-files`, so every page can
read its values. The home page shows the title, the citation, the
contact, the Zenodo values, and the data files. Change them in
`_supplement.yml`, not in `index.qmd`. The page footer shows the two
licenses. No page shows the preprint or author values yet. Values are
Markdown, so `*Journal Name*` shows in italics.

The home page shows the values with these shortcodes:

- `{{< meta supplement.paper-title >}}` and
  `{{< meta supplement.citation >}}` show the paper title and the citation.
  The same form shows any other single value, for example
  `{{< meta supplement.contact >}}` or
  `{{< meta supplement.license.code >}}`. It does not show the `authors`
  list or the `license` group as a whole.
- `{{< supplement-doi >}}` shows a Zenodo DOI badge that links to
  `https://doi.org/` and the DOI. It uses `zenodo.version-doi`. When that
  value is empty, it uses `zenodo.concept-doi`. When both are empty, it
  shows nothing. A `doi:` or `https://doi.org/` in front of the DOI is
  removed. If either value is not a DOI, for example `doi:` alone, the
  render stops with an error that names the field.
- `{{< supplement-download >}}` shows a link to `zenodo.archive-url`. When
  that value is empty, it shows nothing.
- `{{< supplement-data-table >}}`, on a line by itself, shows a table with
  one row for each entry under `data`: the file name as a download link,
  the description, and the file size. Sizes use 1 KB = 1000 bytes. Write
  each `file` relative to this folder, for example `data/example.csv`. The
  table works on any page, and its links are relative to that page.
- `{{< supplement-license code >}}` and
  `{{< supplement-license content >}}` show `license.code` and
  `license.content`. The page footer in `_quarto.yml` uses them. A common
  id shows as a readable name, for example `CC-BY-4.0` as CC BY 4.0. Any
  other id shows as written, and an empty value shows nothing. Each name
  links to the id's page on spdx.org, which has pages only for the ids
  on its lists. The render stops on an id of the wrong
  form. "License ids" in the Reference part gives the form.

If you turn on Zenodo's GitHub integration for this repository, Zenodo
gives the DOIs after the next GitHub release. The version DOI names
one release, and the concept DOI names every release. Add them and the
archive link to `_supplement.yml`, then render the site again. Write each
DOI as, for example, `10.5281/zenodo.1234567`. A `doi:` or
`https://doi.org/` in front is removed.

If a file under `data` does not exist, or names a folder, the render stops
with an error that names it. A site without its data files must not be
published. Quarto copies each file that the table links into `docs/`.
Use data file names made of letters, digits, `.`, `-`, and `_`, with no
two of those symbols in a row. "File names in `_supplement.yml`" in the
Reference part says why.

The shortcodes come from the extension in `_extensions/supplement/`. Commit
that folder with the rest of the site.

## Citation files

The supplement R package writes two files from `_supplement.yml`. Run
these in R from this folder:

```r
supplement::write_citation()
supplement::write_zenodo()
```

`write_citation()` writes `CITATION.cff`, which GitHub reads to show a
citation for the repository. `write_zenodo()` writes `.zenodo.json`. When
Zenodo archives a GitHub release, it reads that file. Both files take the
title, the version, and the authors from `_supplement.yml`, and they
leave out an empty version. `CITATION.cff` also takes
both licenses and the concept DOI. When the two license ids differ only
in letter case, it takes the one spelled as in `license.code`. If the
concept DOI is empty, it takes
the version DOI. `.zenodo.json` also takes the citation. Its
`license` field holds one license, so it gets the content license. Give
each author a `family` name and `given` names. When a file exists, the
functions stop. To write it again after you change `_supplement.yml`, use
`overwrite = TRUE`. Commit both files.

## Checks before a release

Before a GitHub release, run this in R from this folder:

```r
supplement::check_supplement()
```

It changes no file. It prints each problem and returns the problems as a
data frame. `supplement::check_supplement(web_links = TRUE)` also requests
each web address on the site's pages and gives a row for each one that
fails. This needs a network, and a release does not run it. It finds:

- files larger than 100 MiB, which GitHub refuses
- `.rds`, `.rda`, `.RData`, `.qs`, and `.qs2` files that git tracks or
  does not ignore
- files in `figures/`, `docs/`, and `_freeze/` that git ignores, which a
  release leaves out
- reports directly in `analyses/` with code and no stored output in
  `_freeze/`
- reports directly in `analyses/` whose stored output in `_freeze/` came
  from other text than the report holds now
- reports directly in `analyses/` whose source hash in `_freeze/` cannot
  be read
- reports directly in `analyses/` whose stored output gives another MD5 of
  `_scripts/report.R` than the file has now
- folders in `_freeze/analyses/` that no file or folder in `analyses/`
  names, as after a report is deleted or renamed
- reports directly in `analyses/` that name a missing
  `_scripts/report.R` file
- a missing `docs/` folder
- relative `href`, `src`, and `xlink:href` links in `docs/` to files that
  are not in `docs/`, or to folders there with no `index.html`
- symbolic links in `docs/` to existing files or folders outside `docs/`,
  and on Windows junctions to folders outside `docs/`
- pages in `docs/` that cannot be read
- figures whose copy in `docs/figures/` is missing or differs (render the
  whole site, then commit `figures/`, `docs/`, and `_freeze/`)
- a DOI in `CITATION.cff` or on the home page's badge that differs from
  `_supplement.yml`, and a `CITATION.cff` that cannot be read
- template placeholders left in place, such as the paper title in
  `_supplement.yml` or the unchanged example report
  (`?supplement::check_supplement` lists them all)
- with `supplement::check_supplement(renv_lock = TRUE)` only, reports
  whose stored output names R or package versions other than those in
  `renv.lock` (see "Recording R packages with renv"). A release does not
  run this check.
- with `supplement::check_supplement(renv_lock = TRUE)` only, reports
  that attached a package that `renv.lock` does not name. A release does
  not run this check either. When renv picks a profile for the site, these
  two checks read the profile's lockfile in place of `renv.lock`.

The first three checks read the file list from git. When git cannot run or
this folder is not in a git work tree, the function skips them and says
so.

## Make a release

`version` in `_supplement.yml` is the version of this site, written as
three whole numbers such as `"1.0.0"`. Leave it `""` until the first
release. To make a release, run this in R from this folder:

```r
supplement::release_supplement("major")
```

Give `"patch"`, `"minor"`, `"major"`, or a version such as `"1.0.0"`. A
word raises that part of the version and sets the parts after it to 0, and
an empty version counts as `0.0.0`. If a value in `_supplement.yml` stops
`write_citation()` or `write_zenodo()`, the function also stops and
changes no file. Its error has the same class and message. Before it changes any file, the
function runs `check_supplement()`. When that finds a problem or skips its
git checks, the function stops and changes no file. If `_supplement.yml`,
`CITATION.cff`, or `.zenodo.json` changes while the check runs, the
function also stops and writes none of these files. A DOI in
`CITATION.cff` that differs from `_supplement.yml` does not stop it,
because the release writes that file again. It then changes the version
in `_supplement.yml` and writes `CITATION.cff` and `.zenodo.json` again.
Last, it prints the git commands that commit the site and push it, and
then how to publish the release on GitHub. It runs none of the commands
and opens no page. Run the commands yourself in this folder, or commit and
push in the Git pane of RStudio or Positron. Then publish the release on
GitHub's page: when the `origin` remote is on GitHub, the function prints
the address of GitHub's new-release form with the tag filled in. When you
publish the release, GitHub makes the tag on the default branch. So push
before you publish. The printed `git status -- .` shows only files under this folder, and
`git add -A -- .` and `git commit -m "Release vX.Y.Z" -- .` stage and
commit only these files. These are the files that the file size and saved
object checks of `check_supplement()` read. If this folder
is a subfolder of its repository, changes outside it stay out of the
release commit. A file outside this folder that was staged before the
release stays staged, so a later `git commit` adds it.
After Zenodo archives the release, add the new version DOI to
`_supplement.yml` and render the site again.

## How the site renders

The site uses Quarto's freeze option (`execute: freeze: true`). A full
render is `quarto render` with no file name. It uses the stored output in
`_freeze/`, so a report that already holds stored output runs no code. A
report with no stored output runs once, so it needs its data, its fit files,
and R.

A full render does not pick up changes to a report that already holds
stored output. A render by name, such as `quarto render
analyses/example.qmd`, always runs that report's code. Use it to re-run one
report after you change it. `quarto preview` also runs a report's code each
time you save its file.

After you delete or rename a report, delete its folder under the old name
in `_freeze/analyses/`. Also remove or change its item in the Analyses
menu of `_quarto.yml`. Then run a full render. It clears `docs/`, so the
old page does not stay on the site. A renamed report has no stored output
under its new name. So the full render runs its code, which needs its
data, its fit files, and R. Then commit the deleted or renamed report,
under its old path and any new path, with `_quarto.yml`, `_freeze/`,
`docs/`, and `figures/`. The figures that
a deleted report saved stay in `figures/` and on the site. To take one off
the site, see "Paper figures".

After you change a report, render it by name and then render the whole
site. Then commit the report with `_freeze/`, `docs/`, and `figures/`. The
full render copies into `docs/` the figures that the render by name saved
under new names.

With the supplement R package installed, you can run these renders from
the R console, in this folder. `supplement::render_supplement()` renders
the whole site, as `quarto render` does.
`supplement::render_supplement("example")` renders
`analyses/example.qmd` by name and then the whole site. When a full render
saves a figure under a new name in `figures/`, the function renders the
whole site once more. It runs no git command, so commit as above.

## Rendering on the machine with the private data

If a report needs private data or saved model fits, render it on the
machine that holds them. Keep fit files in `analyses/fits/`, which
`.gitignore` keeps out of git. A report's code reads them through `site`,
the site folder (see "Paper figures"), as
`file.path(site, "analyses", "fits", ...)`.

1. Before a full render, check the `.rds` fit files of each report that
   has no stored output in `_freeze/` yet. Before a render by name, check
   that report's fit files. A missing fit file can make a report refit its
   model, which can take hours and give new estimates.
2. Run `quarto render`. It runs the code of each report that has no
   stored output and reuses the stored output of the others. To re-run a
   changed report, render it by name with
   `quarto render analyses/<name>.qmd`, then render the whole site with
   `quarto render`. If a full render saved a figure under a new name in
   `figures/`, run `quarto render` again (see "Paper figures"). From the R
   console, `supplement::render_supplement()` does the full render, and
   `supplement::render_supplement("<name>")` does the render by name and
   then the full render. Either one renders the whole site again after a
   new figure name.
3. Stage only the reports that you added or changed, `_freeze/`, `docs/`,
   and `figures/`, commit, and push. Put the path of each such report in
   place of `analyses/<name>.qmd`:

   ```
   git add analyses/<name>.qmd _freeze docs figures
   git commit -m "Render reports"
   git push
   ```

   If no report was added or changed, leave out `analyses/<name>.qmd`. If
   you added a report with `add_report()`, or deleted or renamed a report,
   also stage `_quarto.yml`, which holds its menu item. For a deleted or
   renamed report, also stage its old path, so the commit records that the
   old file is gone. When a path is missing from disk and git tracks no
   file under it, `git add` stops and stages nothing. So for a site with
   no `figures/` folder, leave out `figures`.

Never publish a build that ran with the data deleted. It drops the data
files from `docs/`, so the download links break.

Every file in `data/` is published on the site. Share open data as CSV or
another plain format there, and keep private data out of the folder.
`.gitignore` blocks `.rds`, `.rda`, `.RData`, `.qs`, and `.qs2` files
everywhere, in any letter case. Saved R objects such as fitted models can
embed the data. Such a file in `data/` is copied to `docs/` but
never committed, so its download link breaks. `check_supplement()`
reports the copy in `docs/data/` as a file that git ignores. Remove the
file from `data/` and render the whole site again.

## Recording R packages with renv

renv is an R package that records the version of each package that a
project uses. It keeps those packages in a library inside the project
folder, so another machine can install the same versions. Install renv,
then run these commands in R from this folder.

1. Set up renv once:

   ```r
   renv::init()
   ```

   It finds the packages that the reports use and adds them to a library
   in `renv/library/`. It writes `renv.lock`, `.Rprofile`, and the files in
   `renv/`. Commit these files. The file `renv/.gitignore` keeps
   `renv/library/` out of git. Later, to add a package that a report
   needs, start R in this folder and run `install.packages()`. R installs
   the package in `renv/library/`.
2. After you render a report, record the packages that the reports use:

   ```r
   renv::snapshot()
   ```

   It writes the version of each package that the reports use, with the
   packages that those need, to `renv.lock`. Commit `renv.lock` with the
   stored output of the render. If you follow "Rendering on the machine
   with the private data", add `renv.lock` to its `git add` command.
3. On another machine, clone the repository and start R in this folder.
   `.Rprofile` loads renv from `renv/library/`. If renv is not in that
   library, `.Rprofile` first copies it from renv's cache or downloads it.
   Install the versions that `renv.lock` records:

   ```r
   renv::restore()
   ```

   Then render one report by name, for example `quarto render
   analyses/example.qmd`. Its code runs with the packages in
   `renv/library/`.

When every report holds stored output in `_freeze/`, a full render runs
no R. It then needs neither renv nor the packages. Only a report with no
stored output runs its code in a full render.

`renv.lock` shows the packages at the last snapshot. Each report's
Computing environment section shows the packages of its own last render.
The two can differ. A report that you render by name after the last
snapshot shows the packages of that render. `renv.lock` shows them only after the
next `renv::snapshot()`.

To list the reports whose versions differ from `renv.lock`, run in R:

```r
supplement::check_supplement(renv_lock = TRUE)
```

Each such report gets a `"renv-mismatch"` row that names the versions.
To use the versions in `renv.lock`, run `renv::restore()`. Then render the
report by name, render the whole site, and commit the report with
`_freeze/`, `docs/`, and `figures/`. If the library now holds the versions of the report, you
can run `renv::snapshot()` and commit `renv.lock` instead.

`supplement::check_supplement(renv_lock = TRUE)` also gives a
`"renv-missing"` row for each report whose stored output shows an
attached package that `renv.lock` does not name.
An example is a package that the report loads with `library()`.
`renv::restore()` does not install such a package from `renv.lock`. Run `renv::snapshot()`
and commit `renv.lock`. If the report no longer uses the package, render
the report by name. Then render the whole site, and commit the report with
`_freeze/`, `docs/`, and `figures/`. A package that a report loaded and
did not attach gives no row. A package that your R profile attaches during
a render also gives a row, and these steps do not clear it.

When renv picks a profile for the site, these two checks read the
profile's lockfile, `renv/profiles/<name>/renv.lock`, in place of
`renv.lock`. renv takes the
name of the profile from `RENV_PROFILE` or the first line of
`renv/profile`. Run the renv commands in the steps of both checks with
that profile active.

A release does not run these checks, so their rows do not stop a release.

## Running reports in a container

Docker runs a program in a container, an isolated system built from an
image. After you set up renv, supplement can write the recipe for an image.
The recipe uses the site's lockfile, which is `renv.lock` unless renv picks
a profile for the site, as below. In this part, `renv.lock` means the
lockfile that the recipe uses.
The image holds the R version and the R packages in `renv.lock`, and Quarto. A
report that you render in that image runs with those versions. This works
on a machine that runs Docker with Linux containers on an amd64 processor,
or on arm64 for R 4.1.0 or later.
`renv.lock` must record R 4.0.0 or later and renv 1.3.1 or later.

renv can pick a profile for the site, from `RENV_PROFILE` or the first
line of `renv/profile`. Then the recipe uses the profile's lockfile,
`renv/profiles/<name>/renv.lock`. The image then sets `RENV_PROFILE` to
the name, so each render in it uses that profile. The name can hold only
ASCII letters, digits, `.`, `_`, and `-`, and it cannot start with `.`.

1. Write the recipe. In R, in this folder, run:

   ```r
   supplement::write_dockerfile(quarto = "1.10.19")
   ```

   Give the Quarto version that you render with. `quarto --version` in a
   terminal shows it. The function writes `Dockerfile` and
   `.dockerignore`. Commit both files.
2. Build the image. In a terminal, in this folder, run:

   ```
   docker build -t my-supplement .
   ```

   The image starts from `rocker/r-ver` with the R version in
   `renv.lock`. The build installs Quarto, the Ubuntu packages that renv
   lists for the R packages, and the R packages, renv included.
   `.dockerignore` lets only that lockfile of this folder's files into the
   image, so the image holds no other file from this folder and no data.
3. Render one report in the image, with this folder mounted at `/site`. On
   macOS and Linux, run:

   ```
   docker run --rm --network none --user "$(id -u):$(id -g)" -e HOME=/tmp \
     -v "$PWD":/site my-supplement quarto render analyses/example.qmd
   ```

   The render reads the data in this folder and writes the stored output
   and the page here. `--network none` shows that the render needs nothing
   from the network. On Linux, `--user` makes you the owner of the files
   that it writes. Docker Desktop on macOS does that without it. The report's Computing environment section then shows the R
   version and the packages of the image.

After `renv::snapshot()` changes `renv.lock`, build the image again. If the
R version or the renv version in `renv.lock` changed, first run
`write_dockerfile()` again with `overwrite = TRUE`. If you pinned the base
image as below, show the digest of the new tag and give that digest. The
old digest names the old image, whatever the tag says.

A tag such as `rocker/r-ver:4.6.1` can move to a newer image, so a later
build can get newer system libraries. To pin the base image, show the
digest of its multi-platform index:

```
docker buildx imagetools inspect rocker/r-ver:4.6.1
```

Copy the value after `Digest:` at the top of the output, and write the
recipe again with it:

```r
supplement::write_dockerfile(quarto = "1.10.19", digest = "sha256:...", overwrite = TRUE)
```

The build also installs Ubuntu packages for the R packages. These come
from Ubuntu's package archive at build time, so they can still be newer in
a later build.

To keep the built image, save it to a file and archive the file:

```
docker save -o my-supplement.tar my-supplement
```

`docker load -i my-supplement.tar` reads the image back. The Zenodo archive
of a GitHub release holds the committed `Dockerfile` and `.dockerignore`,
but not the image.

## Stable figures

Call `set.seed(` with a fixed number before each random draw, for example
before `pp_check()` or a bootstrap. Without a seed, every render that runs the
report's code redraws the figures. The numbers can stay the same while the
figures change.

## Paper figures

Save each figure for the paper in `figures/`. During a render, Quarto sets
`QUARTO_PROJECT_DIR` to the site folder. When you run a report's code by
hand, the variable is usually missing. If it is missing or empty, the
code looks for `_quarto.yml` in the current folder and then in the folder
above it. It uses the first folder that holds the file. If neither holds
it, the code stops and says to run it from the site folder or from
`analyses/`. So a report finds the site folder as:

```r
site <- Sys.getenv("QUARTO_PROJECT_DIR")
if (!nzchar(site)) {
  site <- Find(function(dir) file.exists(file.path(dir, "_quarto.yml")), c(".", ".."))
}
if (is.null(site)) {
  stop("Run this code from the site folder or from its analyses/ folder.")
}
source(file.path(site, "_scripts", "report.R"), local = TRUE)
```

These lines are the `site` chunk of the example report. `add_report()`
writes the same chunk as the first chunk of each new report. If
`_quarto.yml` sets `execute-dir: project`, this path also works. The last
line reads `_scripts/report.R` (see "Shared report code").

To save a figure in your own report, call `save_png()` after the chunks
that make your plot's data. For example, this line saves a plot of a
model `fit`:

```r
save_png("model-fit.png", function() plot(fit))
```

`save_png()` saves into the `figures/` folder of the site. If `figures` is
a link, or on Windows a junction, the function stops with a message. A
link can send the figures outside the site, and git commits a symbolic
link without the figures. If `figures` is a file and not a folder, the
function also stops. If the folder is missing, as in a new clone, the
function makes it, because git does not keep empty folders.

In the example, `save_png()` saves `figures/bootstrap-means.png`. It takes
a function that draws the plot. For a ggplot `p`, pass
`function() print(p)`. It draws into a temporary file in `figures/`.
Then it checks the end of the file. A whole PNG file ends with the PNG
end chunk, its last 12 bytes. The function gives the file its name only
after the plot succeeds and the file has that end. Otherwise it stops
with a message. So a failed plot, or a file that a full disk cut short,
leaves no partial file there. `.gitignore` blocks the temporary files, in
case R stops before it removes one. When the report's code does not
run, these checks do not run. A full render that reuses `_freeze/` does not run it.

The template ships `figures/bootstrap-means.png`, so the first render of a
new site publishes it. Quarto copies `figures/` into `docs/`, so each
figure has a web address such as
`https://jmgirard.github.io/supplement-publish-walk/figures/model-fit.png`. Every file in
`figures/` is published on the site, so keep drafts and private files out
of it.

Each render copies only the figures that were in `figures/` at its start.
After a render saves a figure under a new name, render the whole site
again with `quarto render`, so that `docs/` holds it. Then commit
`figures/`, `docs/`, and `_freeze/`. If a full render from
`supplement::render_supplement()` saves a figure under a new name, the
function renders the whole site again itself. To take a figure off the site, delete
it from `figures/` and run a full render.

PNG and PDF files saved directly in `analyses/` are not committed, because
`.gitignore` blocks them there in any letter case, such as
`analyses/plot.PNG`. Save paper figures in `figures/` instead.

## Publishing from one machine

Render and push the site from one machine. The theme file name in
`docs/site_libs/` is a hash of the compiled theme, which can differ between
machines, for example with another Quarto version. A render on a second
machine can then change every page. A report rendered there also shows that
machine's versions in its Computing environment section.

## Site search

Every page is in the site search by default. To leave a page out of search,
add this to its front matter:

```yaml
search: false
```

## Reference

### License ids

`license.code` and `license.content` in `_supplement.yml` hold SPDX ids.
SPDX is a project that keeps a list of software and content licenses.
Each license name on the site links to `https://spdx.org/licenses/<id>.html`,
a page that SPDX keeps only for ids on its license and exception lists.
Write each id as letters and digits, with one `.` or `-` between groups
and at most one `+` at the end. Other values, for example `CC BY 4.0`,
`GPL--3.0`, or a list, stop the render with an error that names the
field. `write_citation()` refuses these values too.

### File names in `_supplement.yml`

Quarto reads each value in `_supplement.yml` as Markdown, so some
characters in a file name change before the shortcode sees it. For
example, `a--b.csv` becomes `a–b.csv` and `_raw_.csv` becomes `raw.csv`.
Windows cannot use a name that ends in `.`. It also cannot use a name
whose part before the first `.` is a device name, such as `con.csv`.
`add_data()` refuses both kinds of name.

### Setup scripts

Quarto runs two Lua scripts in `_scripts/` on each render, through
Pandoc. They need no R.

- `setup.lua` runs before the render. On the first render it renames
  `_gitignore` to `.gitignore` and `_README.md` to `README.md`, because
  `quarto use template` does not copy those names. When `.gitignore` already
  exists, it adds the rules that it lacks. It then ends the file with
  `!docs/` and `!_freeze/`, so an earlier `docs/` rule cannot hide the
  site. These two lines cannot undo a rule such as `docs/*` or `*.html`.
  Remove such a rule by hand. When `README.md` already exists, it keeps
  that file and removes `_README.md`.
- `nojekyll.lua` runs after the render and writes `docs/.nojekyll`, so that
  GitHub Pages serves the site as it is.
