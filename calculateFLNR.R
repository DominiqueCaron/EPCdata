# Estimate FLNR (fraction of leaf nitrogen allocated to RuBisCO) per
# species from TRY leaf-nitrogen-per-area and Vcmax25 (maximum carboxylation
# rate at 25C) measurements. 
# Writes outputs/flnr_estimate.csv, used by mergeDB.R.
library(data.table)
# Get downloaded data
try_flnr <- reproducible::prepInputs(
  targetFile = "46349.txt",
  destinationPath = "data/TRY_flnr/",
  url = "https://drive.google.com/file/d/1WbU1w8jBhCpUPojZ_jcs8fLC9SKzDuYt/view?usp=sharing",
  fun = "rtry::rtry_import"
)

# Extract leaf nitrogen content
try_lna <- try_flnr[TraitID == 50, .(AccSpeciesName, StdValue)]
try_lna <- aggregate(StdValue ~ AccSpeciesName, data = try_lna, FUN = "mean")
colnames(try_lna) <- c("species", "lna")

# Extract vcmax 
try_vcmax <- try_flnr[TraitID == 186, .(AccSpeciesName, StdValue, DataName)]
# make sure we only have vcmax at 25degrees
try_vcmax <- try_flnr[DataName %in% c("Photosynthetic carboxylation capacity (Vcmax, Vmax) per leaf area at 25 C", "Maximum rate of Rubisco activity, on a projected area basis"), .(AccSpeciesName, StdValue)]
try_vcmax <- aggregate(StdValue ~ AccSpeciesName, data = try_vcmax, FUN = "mean")
colnames(try_vcmax) <- c("species", "vcmax")

# VCmax can be underestimated for some ENF species (see White et al., 2000), remove very low values
try_vcmax <- try_vcmax[try_vcmax[, "vcmax"] > 20, ]

# combine leaf nitrogen content with vcmax, per species
try_flnr <- merge(try_lna, try_vcmax)
# function to calculate fraction of nitrogen in Rubisco
# VCmax25 = alpha15 * LNA * fNR * flnr
flnr <- function(lna, vcmax){
  # alpha_25: maximum rate of RuBP carboxylation per unit RuBisCO protein
  alpha_25 <- 47.34
  # fnr: mass ratio of RuBisCO molecule to N in RuBisCO molecule
  fnr <- 6.25
  flnr <- vcmax/(alpha_25 * fnr * lna)
  return(flnr)
}

# calculate flnr and write the per-species estimate used by mergeDB.R
try_flnr$flnr <- flnr(try_flnr$lna, try_flnr$vcmax)

fwrite(try_flnr, "outputs/flnr_estimate.csv")
