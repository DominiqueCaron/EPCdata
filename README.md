# EPCdata

Scripts and data used to build the default **ecophysiological constants (EPC)** table for
Canadian tree species, used by the `BiomeBGC_dataPrep` SpaDES module when it runs Biome-BGC
without site-specific calibration.

"Ecophysiological constants" are the ~43 species- or forest-type-specific parameters Biome-BGC
needs to simulate a given tree species or plant functional type (PFT) — things like how carbon
is allocated between leaves, stems, and roots, leaf lifespan, C:N ratios of different tissues,
and stomatal conductance. This repository estimates default values for 37 Canadian tree
species from published trait databases, so that `BiomeBGC_dataPrep` has a reasonable starting
point when a user hasn't supplied their own calibrated values.

The methodology is written up in more detail in this Google Doc ("BiomeBGC - EPC", an appendix
intended for a related manuscript): see
https://docs.google.com/document/d/1lCbybMmwN5bDAqBOO-l6wkoj0NgcLgIlMBK90XsMT-E/edit.

## Data sources

Trait values are pooled from seven sources, each contributing some subset of the 43
constants. **None of these raw files are committed to this repository** — each is downloaded
on demand from Google Drive via `reproducible::prepInputs()` into a git-ignored `data/` cache
(see "Data access and licensing" below for which sources are access-restricted):

- **White et al. (2000)** — EPC values compiled from the original Biome-BGC literature, spread
  across five source spreadsheets (cached at `data/white_model_parameters_652/`).
- **Hessl et al. (2004)** — a database of EPC values by species (cached at
  `data/ParameterValues.txt`, `data/Species.txt`).
- **TRY** (https://www.try-db.org) — a global plant trait database. Used here for three
  separate extracts: general trait values including maximum stomatal conductance (cached at
  `data/TRY/46297.txt`), leaf nitrogen content and Vcmax25 for the RuBisCO-fraction calculation
  (cached at `data/TRY_flnr/46349.txt`), and leaf lifespan (cached at
  `data/TRY_longevity/47258.txt`). **These extracts are hosted on a restricted-access Google
  Drive folder** — see "Data access and licensing" below.
- **BOREAS** — Bond-Lamberty et al. (2005) and Kimball et al. (1997) boreal-forest parameter
  compilations (cached at `data/BondLamberty2004.csv`, `data/Kimball1996.csv` — note the
  filenames use different years than the actual publication dates cited below).
- **NACP-TERRA-PNW** — Berner & Law (2016) leaf-trait data for Pacific Northwest tree species
  (cached at `data/NACP_TERRA-PNW_1292/`).
- **TOPIC** — a Sudbury, Ontario tree-trait dataset (cached at
  `data/topic_sud-data_donnees_v2021-10.csv`), used here for leaf carbon-to-nitrogen ratio.
- **S-Trait** — Murray et al. (2019), a compiled dataset of maximum stomatal conductance for
  woody species (cached at `data/STrait_MurrayEtAl2019.csv`, renamed from the source's much
  longer original filename to avoid Windows path-length limits once `prepInputs()` appends its
  checksum-hash suffix).

`parameterList.csv` is the lookup table mapping each of the 43 EPC parameters to the column/ID
used by each source. `speciesList.csv` and `speciesListFull.csv` define the 37 target Canadian
species and their mapping to plant functional types (ENF = evergreen needleleaf, DBF =
deciduous broadleaf, DNF = deciduous needleleaf, i.e. larch).

### References

- White, M. A., Thornton, P. E., Running, S. W., & Nemani, R. R. (2000). Parameterization and
  sensitivity analysis of the BIOME–BGC terrestrial ecosystem model: Net primary production
  controls. *Earth Interactions*, 4(3), 1-85.
- Hessl, A. (2004). *Ecophysiological parameters for Pacific Northwest trees* (Vol. 618). US
  Department of Agriculture, Forest Service, Pacific Northwest Research Station.
- Kattge, J., Bönisch, G., Díaz, S., et al. (2020). TRY plant trait database – enhanced
  coverage and open access. *Global Change Biology*, 26, 119–188.
  https://doi.org/10.1111/gcb.14904
- Luo, X., Keenan, T. F., Chen, J. M., Croft, H., Colin Prentice, I., Smith, N. G., ... &
  Zhang, Y. (2021). Global variation in the fraction of leaf nitrogen allocated to
  photosynthesis. *Nature Communications*, 12(1), 4866. (Basis for the FLNR/RuBisCO-fraction
  calculation in `calculateFLNR.R`, applied to TRY leaf-nitrogen and Vcmax25 data.)
- Bond-Lamberty, B., Gower, S. T., Ahl, D. E., & Thornton, P. E. (2005). Reimplementation of
  the Biome-BGC model to simulate successional change. *Tree Physiology*, 25(4), 413-424.
- Kimball, J. S., Thornton, P. E., White, M. A., & Running, S. W. (1997). Simulating forest
  productivity and surface–atmosphere carbon exchange in the BOREAS study region. *Tree
  Physiology*, 17(8-9), 589-599.
- Berner, L. T., & Law, B. E. (2016). Plant traits, productivity, biomass and soil properties
  from forest sites in the Pacific Northwest, 1999–2014. *Scientific Data*, 3(1), 160002.
  (NACP-TERRA-PNW.)
- Santala, K., Cardou, F., Yemshanov, D., Campioni, F., Simpson, M., Handa, I. T., Ryser, P.,
  & Aubin, I. (2022). Finding the perfect mix: An applied model that integrates multiple
  ecosystem functions when designing restoration programs. *Ecological Engineering*, 180,
  106646. https://doi.org/10.1016/j.ecoleng.2022.106646 (TOPIC.)
- Murray, M., Soh, W. K., Yiotis, C., Batke, S., Parnell, A. C., Spicer, R. A., ... &
  McElwain, J. C. (2019). Convergence in maximum stomatal conductance of C3 woody angiosperms
  in natural ecosystems across bioclimatic zones. *Frontiers in Plant Science*, 10, 558.
  (S-Trait.)

## Data access and licensing

None of the raw source files are stored in this git repository. Instead, both `mergeDB.R` and
`calculateFLNR.R` fetch each source via `reproducible::prepInputs()` from a Google Drive URL
hard-coded at the relevant `prepInputs()` call, caching the download under `data/` (git-ignored)
on first run.

- **TRY data are restricted-access.** TRY (https://www.try-db.org) releases raw trait records
  to individual requesters under its own data-use rules (see the
  `TRY_Intellectual_Property_Guidelines.pdf` that accompanies any TRY request), which generally
  do not permit redistributing the raw export to third parties. The three TRY extracts used
  here (general traits/stomatal conductance — request 46297; leaf nitrogen and Vcmax25 for FLNR
  — request 46349; leaf lifespan — request 47258) are hosted on a restricted-access Google
  Drive folder, viewable only to approved collaborators. Users without access must request
  their own TRY data release (same request numbers, or equivalent trait/species selections) and
  either host their own copies at the same Google Drive URLs, or edit the corresponding
  `prepInputs()` calls in `mergeDB.R`/`calculateFLNR.R` to point at a local file instead.
- The remaining source datasets (White et al. 2000, Hessl et al. 2004, BOREAS, NACP-TERRA-PNW,
  TOPIC, S-Trait) are also hosted on Google Drive and downloaded the same way via
  `prepInputs()`, but their sharing links are not access-restricted. 

## Pipeline

Run `calculateFLNR.R` first, then `mergeDB.R` (which reads `calculateFLNR.R`'s output).

1. **`calculateFLNR.R`** — estimates FLNR, the fraction of leaf nitrogen allocated to the
   photosynthetic enzyme RuBisCO, from TRY leaf-nitrogen and Vcmax25 (maximum carboxylation
   rate) measurements, using the formula from Biome-BGC's underlying photosynthesis model.
   Writes `outputs/flnr_estimate.csv`.
2. **`mergeDB.R`** — the main pipeline:
   - downloads (via `prepInputs()`, from Google Drive) each of the seven sources above and
     standardizes them to a common
     `ParId, parameter, species, value, originalRef, source` format (fixing known species-name
     typos and source-specific quirks along the way, e.g. swapped columns, unit conversions);
   - flags duplicate entries and restricts to the 37 target species;
   - produces exploratory plots of data coverage and value distributions by parameter and
     species (these are for visual inspection only; nothing downstream depends on them);
   - removes values identified as outliers by visual inspection (documented inline, e.g.
     implausible C:N or lignin/cellulose fractions);
   - averages to one value per **species** for 7 constants that benefit from species-level
     resolution (leaf/fine-root turnover, three C:N ratios, specific leaf area, maximum stomatal
     conductance, FLNR) and writes `outputs/speciesLevelEPC.csv`;
   - averages the remaining constants to one value per **PFT** (using
     `LandR::sppEquivalencies_CA` to assign each species to ENF/DBF/DNF), renormalizes the
     tissue-fraction constants (cellulose/lignin/labile fractions) so each group sums to 100,
     and writes `outputs/pftLevelEPC.csv`.

## Outputs

| File | Description |
|---|---|
| `outputs/flnr_estimate.csv` | Per-species RuBisCO nitrogen fraction (FLNR) estimate from TRY. |
| `outputs/speciesLevelEPC.csv` | Per-species values for the 7 constants estimated at species resolution. |
| `outputs/pftLevelEPC.csv` | Per-PFT (ENF/DBF/DNF) values for the remaining constants. |
| `outputs/summary.csv` | Count of source entries per parameter x species, for coverage checks. |
| `outputs/defaultEPC.csv` | **Final product**: one row per species, combining the species- and PFT-level tables plus a few additional fields (`PFT`, `woody`, `evergreen`, `c3psn`, `modelPhenology`). |

**Note:** `outputs/defaultEPC.csv` have been assembled by hand from `speciesLevelEPC.csv` and `pftLevelEPC.csv`.

## How this feeds `BiomeBGC_dataPrep`

`outputs/defaultEPC.csv` is uploaded (manually) to Google Drive, and `BiomeBGC_dataPrep`
downloads it from there: `prepEPC()` in `BiomeBGC_dataPrep/R/prepInputFncts.R` fetches the file
from a hard-coded Google Drive URL in `BiomeBGC_dataPrep.R`, filters it to the species the user
has requested, and writes one `.epc` file per species (via `epcWrite2()` in
`BiomeBGC_dataPrep/R/helper.R`) for Biome-BGC to read. There is currently no tracked link (e.g.
a checksum or version tag) between a given commit of this repository and the file sitting
behind that Google Drive URL — updating `defaultEPC.csv` here does not automatically update
what `BiomeBGC_dataPrep` downloads.

---

Drafted with assistance from Claude (Posit Assistant).
