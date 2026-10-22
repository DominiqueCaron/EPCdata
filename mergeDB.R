# Load TRY, White et al. (2000), and Hessl (2004) data
# Standardize format:
## species
## trait
## value
## reference
## original reference
# Combine
# Identify duplicated data

# load package
repos <- c("predictiveecology.r-universe.dev", getOption("repos"))
Require::Require(c('reproducible', 'data.table', 'rtry'), repos = repos)

# species list
speciesList <- read.csv("speciesList.csv", header = FALSE, col.names = "species")
parameterList <- read.csv("parameterList.csv")

# White 2000 data ---------------------------------------------------------
# White et al. (2000) EPC values, split across five source spreadsheets.
# Each spreadsheet is downloaded, cleaned of known species-name typos, and
# standardized to ParId/parameter/species/value/originalRef/source.

## first table
white1 <- prepInputs(
  targetFile = "White_spreadsheet1.csv",
  destinationPath = "data/",
  url = "https://drive.google.com/file/d/1xVNwNenJRXtBKDTmpxMutS7Ipd5NSeWK/view?usp=drive_link",
  fun = "data.table::fread",
  check.names = TRUE
)
### fix some typos
white1$Species[white1$Species == "Prunus pennsylvanica"] <- "Prunus pensylvanica"
white1$Species[white1$Species == "Rubus alleghaniensis"] <- "Rubus allegheniensis"
white1$Species[white1$Species == "Rubus allighaniensis"] <- "Rubus allegheniensis"
white1$Species[white1$Species == "Betula Papyrifera"] <- "Betula papyrifera"
white1$Species[white1$Species == "Sequoiadendron gigant."] <- "Sequoiadendron giganteum"
white1$Species[white1$Species == "Tillia americana"] <- "Tilia americana"

### standardize
white1 <- white1[, .(species = Species, parameter = Abbreviation, value = Value, originalRef = Source, source = "White2000")]
white1 <- merge(white1, parameterList[, c("ParId", "Description", "Abbreviation", "White")], by.x = "parameter", by.y = "White")
white1 <- white1[, .(ParId, parameter = Abbreviation, species, value, originalRef, source)]

## second table
white2 <- prepInputs(
  targetFile = "White_spreadsheet2.csv",
  destinationPath = "data/",
  url = "https://drive.google.com/file/d/1xVNwNenJRXtBKDTmpxMutS7Ipd5NSeWK/view?usp=drive_link",
  fun = "data.table::fread",
  check.names = TRUE
)

### fix some typos
white2$Species[white2$Species == "Abies concolr"] <- "Abies concolor"
white2$Species[white2$Species == "Prunus pensylvannica"] <- "Prunus pensylvanica"
white2$Species <- gsub("Abiea", "Abies",  white2$Species)
white2[white2 == -999] <- NA

white2 <- melt(white2, measure.vars = c("Labile", "Cellulose", "Lignin"))
white2[, Parameter := paste(Parameter, variable)]
white2 <- white2[!is.na(value), ]

## standardize
white2 <- merge(white2, parameterList[, c("ParId", "Description", "Abbreviation", "White")], by.x = "Parameter", by.y = "White")
white2 <- white2[, .(ParId, parameter = Abbreviation, species = Species, value, originalRef = Source, source = "White2000")]

## third table
white3 <- prepInputs(
  targetFile = "White_spreadsheet3.csv",
  destinationPath = "data/",
  url = "https://drive.google.com/file/d/1xVNwNenJRXtBKDTmpxMutS7Ipd5NSeWK/view?usp=drive_link",
  fun = "data.table::fread",
  check.names = TRUE
)
### fix some typos
white3$Species[white3$Species == "Pinus elliotii"] <- "Pinus elliottii"
white3$Species[white3$Species == "Pinus Taeda"] <- "Pinus taeda"
white3$Species[white3$Species == "Robinea pseudoacacia"] <- "Robinia pseudoacacia"

white3[white3 == -999] <- NA # These are incorrect
### except for the lines with NAs, the column are mixed-up
white3[!is.na(white3$Cellulose), c("Lignin", "Cellulose")] <-  white3[!is.na(white3$Cellulose), c("Cellulose", "Lignin")]


white3 <- melt(white3, measure.vars = c("Cellulose", "Lignin"))
white3[, Parameter := paste(Parameter, variable)]
white3 <- white3[!is.na(value), ]

## standardize
white3 <- merge(white3, parameterList[, c("ParId", "Description", "Abbreviation", "White")], by.x = "Parameter", by.y = "White")
white3 <- white3[, .(ParId, parameter = Abbreviation, species = Species, value, originalRef = Source, source = "White2000")]

## fourth table
white4 <- prepInputs(
  targetFile = "White_spreadsheet4.csv",
  destinationPath = "data/",
  url = "https://drive.google.com/file/d/1xVNwNenJRXtBKDTmpxMutS7Ipd5NSeWK/view?usp=drive_link",
  fun = "data.table::fread",
  check.names = TRUE
)
white4[white4 == -999] <- NA

white4 <- melt(white4, measure.vars = c("Initial", "Final"))
white4[, Parameter := paste(Parameter, variable)]
white4 <- white4[!is.na(value), ]

## standardize
white4 <- merge(white4, parameterList[, c("ParId", "Description", "Abbreviation", "White")], by.x = "Parameter", by.y = "White")
white4 <- white4[, .(ParId, parameter = Abbreviation, species = Species, value, originalRef = Source, source = "White2000")]

## fifth table
white5 <- prepInputs(
  targetFile = "White_spreadsheet5.csv",
  destinationPath = "data/",
  url = "https://drive.google.com/file/d/1xVNwNenJRXtBKDTmpxMutS7Ipd5NSeWK/view?usp=drive_link",
  fun = "data.table::fread",
  check.names = TRUE
)
white5[white5 == -999] <- NA

white5 <- melt(white5, measure.vars = c("Initial", "Final"))
white5[, Parameter := paste(Parameter, variable)]
white5 <- white5[!is.na(value), ]

## standardize
white5 <- merge(white5, parameterList[, c("ParId", "Description", "Abbreviation", "White")], by.x = "Parameter", by.y = "White")
white5 <- white5[, .(ParId, parameter = Abbreviation, species = Species, value, originalRef = Source, source = "White2000")]

# Combine the five tables
white2000 <- rbindlist(list(white1, white2, white3, white4, white5))

# Hessl 2004 data ---------------------------------------------------------
# Hessl et al. (2004) EPC database: parameter values keyed by species ID,
# joined against a separate species lookup table.
hessl2004 <- prepInputs(
  "ParameterValues.txt",
  destinationPath = "data/",
  url = "https://drive.google.com/file/d/1o2sllwtnk-5exRkGOZz8wCKUg9aUCln4/view?usp=drive_link",
  fun = "data.table::fread",
  check.names = TRUE
)
colnames(hessl2004) <- c("id", "parameterId", "speciesId", "value", "units", "location", "state", "NoIdea1", "NoIdea2", "NoIdea3", "NoIdea4", "forestType", "ref", "year", "month", "day")

species <- prepInputs(
  "Species.txt",
  destinationPath = "data/",
  url = "https://drive.google.com/file/d/12RLmqwNu-QA6EyAJu9F-gYZ3bo_BvzIQ/view?usp=drive_link",
  fun = "data.table::fread",
  check.names = TRUE
)
colnames(species) <- c("id", "speciesId", "species", "speciesCommonName", "PFT")

hessl2004 <- merge(hessl2004, species[,.(speciesId, species)])


hessl2004 <- merge(hessl2004, parameterList[, c("ParId", "Abbreviation", "Hessl")], by.x = "parameterId", by.y = "Hessl")
hessl2004[, ref := paste(ref, year, sep = ", ")]

hessl2004 <- hessl2004[, .(ParId, parameter = Abbreviation, species, value, originalRef = ref, source = "Hessl2004")]

# Combine with white 2000
epc <- rbindlist(list(white2000, hessl2004))

# TRY data ----------------------------------------------------------------
# General trait extract from the TRY database (https://www.try-db.org).
# Filters out White (2000)'s own records (already included above), keeps
# only explicit maximum-stomatal-conductance records (TRY pools several
# conductance definitions under one trait), converts conductance from
# mmol m-2 s-1 to m s-1, and drops SLA (Biome-BGC expects it in mass units
# of carbon rather than dry weight).
try <- rtry::rtry_import("data/TRY/46297.txt")
try <- try[!is.na(TraitID),]

try <- merge(try, parameterList[, c("ParId", "Abbreviation", "TRY")], by.x = "TraitID", by.y = "TRY")

# remove White 2000 data
try <- try[DatasetID != 79, ]
try[, value := fcoalesce(StdValue, as.numeric(OrigValueStr))]
try$UnitName <- ifelse(try$UnitName == "", NA, try$UnitName)
try[, unit := fcoalesce(UnitName, OrigUnitStr)]

# Remove conductance data that are not explicitly the maximum conductance
gsmaxOrigNames <- c("Gmax (mmol m-2 s-1)", 
                   "The stomatal conductance to water vapour under conditions of light saturation, high relative humidit", 
                   "The value of gs in the limit of saturating light, zero VPD, maximum soil water content and at the re",
                   "gwmaxa",
                   "gs_sat")
try <- try[Abbreviation != "G_smax" | OriglName %in% gsmaxOrigNames]

# Put together 
try <- try[ ,.(ParId, parameter = Abbreviation, species = AccSpeciesName, value, unit, originalRef = Reference, source = "TRY")]

# convert conductance from mmol/m2/s to m/s
# assuming Temp = 25deg and 101.3 kPa
try$value[try$ParId == 31] <- try$value[try$ParId == 31] * 2.45 * 10^-5

# Remove SLA, in Biome_BGC it is in in mass units of C not dry weight
try <- try[ParId != 28]

try[, unit := NULL]

epc <- rbind(epc, try)
setorder(epc, ParId, species)


# TRY leaf longevity -----------------------------------------------------------
# A separate TRY extract (TraitID 12, leaf lifespan in months) converted to
# a leaf/fine-root turnover fraction (LFRT = 1 / (lifespan_months / 12)).
# Turnover above 0.9 is treated as fully deciduous (LFRT = 1).
try_leafLongevity <- rtry::rtry_import("data/TRY_longevity/47258.txt")
try_leafLongevity <- try_leafLongevity[TraitID == 12, ]
# change to LFRT id
try_leafLongevity[, TraitID := 474]

# We are only interested of leafLongevity for evergreen species
try_leafLongevity <- merge(try_leafLongevity, parameterList[, c("ParId", "Abbreviation", "TRY")], by.x = "TraitID", by.y = "TRY")

try_leafLongevity[, value := fcoalesce(StdValue, as.numeric(OrigValueStr))]
try_leafLongevity$UnitName <- ifelse(try_leafLongevity$UnitName == "", NA, try_leafLongevity$UnitName)
try_leafLongevity[, unit := fcoalesce(UnitName, OrigUnitStr)]

# Put together 
try_leafLongevity <- try_leafLongevity[ ,.(ParId, parameter = Abbreviation, species = AccSpeciesName, value = 1/(value / 12), originalRef = Reference, source = "TRY")]

# Remove set LFRT to 1 deciduous species
try_leafLongevity[value>0.9, value := 1]

epc <- rbind(epc, try_leafLongevity)
setorder(epc, ParId, species)

# BOREAS data -------------------------------------------------------------
# Boreal-forest EPC values from Bond-Lamberty et al. (2004) and
# Kimball (1996), combined and joined to the parameter lookup table.
bondLamberty2004 <- fread("data/BondLamberty2004.csv")
bondLamberty2004[, source := "Bond-Lamberty2004"]
kimball1996 <- fread("data/Kimball1996.csv")
kimball1996[, source := "Kimball1996"]
BOREAS <- rbind(bondLamberty2004, kimball1996) |> na.omit()

BOREAS <- merge(BOREAS[, Description := NULL], parameterList[, c("ParId", "Abbreviation")])
setnames(BOREAS, old = "Abbreviation", new = "parameter")
BOREAS[, originalRef := NA]

epc <- rbind(epc, BOREAS)


# NACP-TERRA_PNW data -----------------------------------------------------
# Law & Berner (2015) leaf-trait data for Pacific Northwest species:
# specific leaf area, projected leaf-area-to-sapwood-area ratio, leaf C:N,
# and leaf lifespan (converted to LFRT), restricted to the target species.

Law_Berner2015 <- fread("data/NACP_TERRA-PNW_1292/data/NACP_TERRA_PNW_leaf_trait.csv", header = T, na.strings = "-9999")
Law_Berner2015 <- Law_Berner2015[-1,]
Law_Berner2015 <- Law_Berner2015[,.(species = paste(GENUS, SPECIES), SLA = as.numeric(SLA_PSA)*0.1, LAI_all_proj = as.numeric(PSA_to_HSA)*2, CN_leaf = LEAF_CN, LFRT = 1/as.numeric(LEAF_LIFE), source = "Law and Berner2015", originalRef = NA)]
setnames(Law_Berner2015, old = c("LAI_all_proj", "CN_leaf"), c("LAI_all:proj", "C:N_leaf"))
Law_Berner2015 <- Law_Berner2015[species %in% speciesList$species]

Law_Berner2015 <- melt(Law_Berner2015, id.vars = c("species", "source", "originalRef"), variable.name = "parameter", value.name = "value")
Law_Berner2015 <- merge(Law_Berner2015, as.data.table(parameterList)[,.(ParId, parameter = Abbreviation)])

epc <- rbind(epc, Law_Berner2015)

# TOPIC data --------------------------------------------------------------
# Sudbury, Ontario tree-trait dataset. Used here only for leaf C:N ratio,
# computed per sample from paired leaf carbon and nitrogen content, then
# matched back to species.

topic <- fread("data/topic_sud-data_donnees_v2021-10.csv")
# filter tree species
topic <- topic[TOPICSpeciesName_NomEspèceTOPIC %in% speciesList$species & SampleType_TypeÉchantillon != "Understory"]
# to calculate leaf C/N we want: carbon content and nitrogen content and match the samples
topic_CNleaf <- topic[TraitCode %in% c("Leaf_N", "Leaf_C")]
topic_CNleaf <- dcast(topic_CNleaf, formula = SampleID_IDÉchantillon ~ TraitCode, value.var = "ObsTraitValue_ValeurTraitObs")
topic_CNleaf$CN_leaf <- topic_CNleaf$Leaf_C / topic_CNleaf$Leaf_N

topic_CNleaf <- merge(topic_CNleaf, unique(topic[,.(SampleID_IDÉchantillon, species = TOPICSpeciesName_NomEspèceTOPIC)]))
topic_CNleaf <- topic_CNleaf[,.(ParId = 12, parameter = "C:N_leaf", species, value = CN_leaf, originalRef = NA, source = "TOPIC")]

epc <- rbind(epc, topic_CNleaf)

# S-Trait data ------------------------------------------------------------
# Murray et al. (2019) compiled maximum stomatal conductance for woody
# C3 species; restricted to Canadian tree species and converted to
# m s-1 as above.
STrait <- fread("data/Data_Sheet_1_Convergence in Maximum Stomatal Conductance of C3 Woody Angiosperms in Natural Ecosystems Across Bioclimatic Zones.csv", sep= ",")
# Keep Canadian species
STrait <- STrait[Species %in% speciesList$species & `Tree/shrub` == "Tree"]
STrait <- STrait[, .(ParId = 31, parameter = "G_smax", species = Species, value = `Maximum stomatal conductance (porometry) calibrated with IRGA (mmol m-2 s-1)`, originalRef = "Murray et al., 2019", source = "Murray et al., 2019")]
# convert conductance from mmol/m2/s to m/s
# assuming Temp = 25deg and 101.3 kPa
STrait[, value := value * 2.45 * 10^-5 ]
epc <- rbind(epc, STrait)

# Identify duplicates and restrict to the target species list
epc$dup <- duplicated(epc[,.(ParId, species, signif(value, 3))])
epc <- epc[species %in% speciesList$species, ]

# Exploratory plots: coverage and value distributions by parameter and
# species. Visual inspection only -- not used by any downstream step.
# Breakdown across parameters
Require::Require(c("ggplot2", "patchwork"), repos= repos)
epc$parameter <- factor(epc$parameter, levels = parameterList$Abbreviation)
p1 <- ggplot(epc) +
  geom_bar(aes(x = parameter)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(x = "EPC", y = "# of entries")

epcMean <- aggregate(value ~ parameter + species, data = epc, FUN = "mean")
p2 <- ggplot(epcMean) +
  geom_bar(aes(x = parameter)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(x = "EPC", y = "# of species")

p1 + p2

# Breakdown across species
p1 <- ggplot(epc) +
  geom_bar(aes(x = species)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(x = "species", y = "# of entries")

p2 <- ggplot(epcMean) +
  geom_bar(aes(x = species)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(x = "species", y = "# of epc")

p1 + p2

# Distribution of epc values across entries
ggplot(epc) + 
  geom_histogram(aes(x = value)) +
  facet_wrap(~parameter, scales = "free") + 
  labs(y = "# of entries")

# Distribution of epc values across species
ggplot(epcMean) + 
  geom_histogram(aes(x = value)) +
  facet_wrap(~parameter, scales = "free") + 
  labs(y = "# of species")

# Exclude outliers (based on visual inspection of the plots above):
epc <- epc[parameter != "FRC:LC" | value <= 4.5]
epc <- epc[parameter != "C:N_fr" | value <= 100]
epc <- epc[parameter != "C:N_lit" | value <= 120 | species != "Pinus contorta"] # See Thomas and Prescott, values should be around 88
epc <- epc[parameter != "DW_cel" | value >= 60]
epc <- epc[parameter != "DW_lig" | value <= 40]
epc <- epc[parameter != "LFRT" | value > 0.1]

epcMean <- aggregate(value ~ parameter + species, data = epc, FUN = "mean")


# species-level traits ----------------------------------------------------
# Average to one value per species for the 7 constants best resolved at
# species level (turnover, three C:N ratios, SLA, max stomatal
# conductance), add the FLNR estimates from calculateFLNR.R, and write
# outputs/speciesLevelEPC.csv.

speciesLevel <- epcMean[epcMean$parameter %in% c("LFRT", "C:N_leaf", "C:N_fr", "C:N_lit", "SLA", "G_smax", "FLNR"),]
# get the FLNR estimates
flnr <- fread("outputs/flnr_estimate.csv")
flnr <- data.table(
  parameter = "FLNR",
  species = flnr$species,
  value = flnr$flnr
)
flnr <- flnr[species %in% speciesList$species, ]

speciesLevel <- rbind(speciesLevel, flnr)
speciesLevel$value <- signif(speciesLevel$value , 2)

speciesLevel <- dcast(as.data.table(speciesLevel), species ~ parameter, value.var = "value", fun.aggregate = mean)
fwrite(speciesLevel, "outputs/speciesLevelEPC.csv")

# PFT-level traits --------------------------------------------------------
# Assign each species to a plant functional type (ENF/DBF/DNF via
# LandR::sppEquivalencies_CA, with Larix treated as deciduous needleleaf),
# average the remaining constants per PFT, renormalize the
# cellulose/lignin/labile tissue-fraction groups to sum to 100, and write
# outputs/pftLevelEPC.csv.

# Get species functional type
epc <- merge(epc, LandR::sppEquivalencies_CA[,c("Latin_full", "Broadleaf" )], by.x = "species", by.y = "Latin_full")
epc$PFT <- ifelse(epc$Broadleaf, "DBF", "ENF")
epc$PFT[startsWith(epc$species, "Larix")] <- "DNF"
flnr <- merge(flnr, LandR::sppEquivalencies_CA[,c("Latin_full", "Broadleaf")], by.x = "species", by.y = "Latin_full")
flnr$PFT <- ifelse(flnr$Broadleaf, "DBF", "ENF")
epc$PFT[startsWith(epc$species, "Larix")] <- "DNF"

pftLevel <- rbind(epc[,c("species", "parameter", "value", "PFT")], flnr[,c("species", "parameter", "value", "PFT")])
pftLevel <- aggregate(value ~ parameter + PFT, data = pftLevel, FUN = "mean")
pftLevel$value <- signif(pftLevel$value , 2)

pftLevel <- dcast(as.data.table(pftLevel), PFT ~ parameter, value.var = "value")
# for proportion, make sure they sum to 1
cols <- c("DW_cel", "DW_lig")
pftLevel[, (cols) := {
  x <- .SD
  x <- x/rowSums(x)
  round(x, 2) * 100
}, .SDcols = cols]

cols <- c("FR_cel", "FR_lab", "FR_lig")
pftLevel[, (cols) := {
  x <- .SD
  x <- x/rowSums(x)
  round(x, 2) * 100
}, .SDcols = cols]

cols <- c("L_cel", "L_lab", "L_lig")
pftLevel[, (cols) := {
  x <- .SD
  x <- x/rowSums(x)
  round(x, 2) * 100
}, .SDcols = cols]

fwrite(pftLevel, "outputs/pftLevelEPC.csv")
