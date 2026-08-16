# cB58 Galaxy Search — Distributed Spectral Matching

A high-throughput scientific-computing workflow for searching millions of astronomical spectra for candidates resembling **MS 1512-cB58**, a gravitationally lensed high-redshift Lyman-break galaxy.

The project scales a sliding-window spectral similarity search across the UW–Madison Center for High Throughput Computing (CHTC) / HTCondor environment and reduces distributed outputs to the **100 strongest candidate matches**. The original search covered roughly **2.5 million spectra**.

## Highlights

- large-scale search over ~2.5M astronomical spectra
- FITS spectral data processing in R
- sliding-window template matching against the cB58 reference spectrum
- HTCondor job distribution across independent data archives
- deterministic result aggregation and Top-100 candidate ranking
- retained `best100.csv` with the strongest candidates from the original run

## Search method

For each input spectrum, the workflow slides the cB58 reference flux vector across the observed flux sequence. At every valid position it computes Euclidean distance:

\[
d(A,B)=\sqrt{\sum_i (A_i-B_i)^2}
\]

The minimum distance and its spectral index are retained for that spectrum. Independent jobs process different spectral archives, after which the partial CSV outputs are merged and globally ranked.

Each result contains:

- `distance` — minimum cB58/template distance
- `spectrumID` — source FITS spectrum
- `i` — best matching start index within the spectrum

## Repository structure

- `project.R` — core FITS spectral-search algorithm
- `project.sh` — per-job wrapper for an archived spectrum batch
- `project.sub` — generic HTCondor submit description
- `merge.sh` — merges distributed outputs and keeps the global Top 100
- `best100.csv` — retained Top-100 candidates from the original search
- `project.Rmd` — compact analysis/report for the retained candidate set

## Requirements

The core search requires R and the `FITSio` package:

```r
install.packages("FITSio")
```

For distributed execution, an HTCondor/CHTC-style environment is required.

## Run locally

```bash
Rscript project.R cB58_Lyman_break.fit /path/to/spectra results.csv
```

The spectrum directory should contain `.fit` or `.fits` files with a `FLUX`/`flux` column.

## Distributed execution

Prepare one compressed spectrum archive per job and list the archive paths in `archives.txt`:

```text
/path/to/batch_001.tar.gz
/path/to/batch_002.tar.gz
/path/to/batch_003.tar.gz
```

Then submit:

```bash
mkdir -p logs
condor_submit project.sub
```

Each job transfers the reference spectrum, the search code, and one archive, then writes a `result_<job>.csv` file.

## Build the global Top 100

After the distributed jobs complete:

```bash
bash merge.sh best100.csv
```

or explicitly provide result files:

```bash
bash merge.sh best100.csv result_0.csv result_1.csv result_2.csv
```

The merger sorts all candidates by spectral distance and keeps the 100 closest matches.

## Result artifact

`best100.csv` preserves the candidate ranking produced by the original large-scale search. The top recorded candidate is:

```text
distance = 13.78225
spectrum = spec-3586-55181-0001.fits
index    = 4133
```

## Scientific-computing takeaway

The main contribution of this project is the workflow design: convert an expensive brute-force spectral matching problem into many independent batch jobs, distribute them through HTCondor, and reduce the outputs into a globally ranked candidate set. The same pattern applies broadly to parameter sweeps, simulation campaigns, large-scale similarity search, and embarrassingly parallel scientific workloads.
