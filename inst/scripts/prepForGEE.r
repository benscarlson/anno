spsm <- suppressPackageStartupMessages

spsm(library(anno))
spsm(library(docopt))

'Prep for GEE.

Usage:
prepForGEE.r <datPF> [options]

Options:
-h --help     Show this screen.
-v --version     Show version.
--annoPF=<annoPF>
--shpDSN=<shpDSN>
--ptsPerGrpReq=<ptsPerGrp>
--extFields=<extFields>

' -> doc

ag <- docopt(doc, version = '0.1\n')

if(!is.null(ag$ptsPerGrp)) ag$ptsPerGrp <- as.integer(ag$ptsPerGrp)
if(!is.null(ag$extFields)) ag$extFields <- trimws(strsplit(ag$extFields,split=',')[[1]])

prepForGEE(datPF=ag$datPF,
  annoPF=ag$annoPF,
  shpDSN=ag$shpDSN,
  ptsPerGrp=ag$ptsPerGrp,
  extFields=ag$extFields)


