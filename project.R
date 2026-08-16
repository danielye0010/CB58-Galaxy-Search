#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(FITSio))

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: Rscript project.R <reference.fits> <spectra_dir> [output.csv]")
}

reference_file <- args[[1]]
spectra_dir <- args[[2]]
output_file <- if (length(args) >= 3) args[[3]] else "results.csv"

if (!file.exists(reference_file)) {
  stop(paste("Reference FITS file not found:", reference_file))
}
if (!dir.exists(spectra_dir)) {
  stop(paste("Spectra directory not found:", spectra_dir))
}

reference <- readFrameFromFITS(reference_file, header = TRUE)
if (is.null(reference$FLUX)) {
  stop("Reference FITS table must contain a FLUX column")
}
reference_flux <- as.numeric(reference$FLUX)
n_reference <- length(reference_flux)

files <- list.files(
  spectra_dir,
  pattern = "\\.(fit|fits)$",
  full.names = TRUE,
  ignore.case = TRUE
)
if (length(files) == 0) {
  stop(paste("No FITS spectra found in", spectra_dir))
}

euclidean_distance <- function(a, b) {
  if (length(a) != length(b) || anyNA(a) || anyNA(b)) {
    return(Inf)
  }
  sqrt(sum((a - b)^2))
}

search_spectrum <- function(path) {
  spectrum <- readFrameFromFITS(path)
  if (is.null(spectrum$flux)) {
    stop(paste("Spectrum FITS table must contain a flux column:", path))
  }

  flux <- as.numeric(spectrum$flux)
  n_flux <- length(flux)
  if (n_flux < n_reference) {
    return(data.frame(
      distance = Inf,
      spectrumID = basename(path),
      i = NA_integer_
    ))
  }

  starts <- seq_len(n_flux - n_reference + 1L)
  distances <- vapply(
    starts,
    function(j) {
      slice <- flux[j:(j + n_reference - 1L)]
      euclidean_distance(reference_flux, slice)
    },
    numeric(1)
  )

  best <- which.min(distances)
  data.frame(
    distance = distances[[best]],
    spectrumID = basename(path),
    i = starts[[best]]
  )
}

results <- do.call(rbind, lapply(files, search_spectrum))
results <- results[order(results$distance), ]
write.csv(results, output_file, row.names = FALSE)
cat(sprintf("Searched %d spectra; wrote %s\n", nrow(results), output_file))
