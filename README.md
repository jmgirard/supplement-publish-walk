# Supplemental Materials

Supplemental analysis reports, code, and data for: Author, A. A., &
Author, B. B. (Year). Title of the paper. *Journal Name*.

Website: https://jmgirard.github.io/supplement-publish-walk/

## Contents

- `analyses/`: Quarto source files (`.qmd`), one per report
- `data/`: shared data files
- `figures/`: figures for the paper, saved by the reports and published on the site
- `_freeze/`: stored output of each report
- `_supplement.yml`: facts about the paper, such as its title, citation, DOIs, and data files
- `index.qmd`, `_quarto.yml`: website source
- `_extensions/supplement/`: the shortcodes that show the DOI badge, the download link, and the data table
- `docs/`: rendered website, served by GitHub Pages
- `_scripts/`: the scripts that Quarto runs before and after each render, and `report.R`, the R functions that the reports share
- `LICENSE.md`, `LICENSE-CC-BY.md`: the licenses of the code and the content
- `GUIDE.md`: the guide for the site's authors

## License

- Code (the `.qmd` files in `analyses/`, the scripts in `_scripts/`, and
  the website configuration): MIT, see `LICENSE.md`
- Content (rendered reports in `_freeze/` and `docs/`, figures in
  `figures/`, website text, and data files): CC BY 4.0, see `LICENSE-CC-BY.md`. The third-party code that
  Quarto copies into `docs/site_libs/` keeps its own licenses.
