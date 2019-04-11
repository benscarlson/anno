
spsm <- suppressPackageStartupMessages

spsm(library(anno))
spsm(library(docopt))

'Process raw GEE output.

Usage:
  processGEEraw.r <datAnnoPF> [options]

Options:
-h --help     Show this screen.
-v --version  Show version.
--outPF=<outPF>
--rawP=<rawP>

' -> doc

ag <- docopt(doc, version = '0.1\n')

processGEEraw(datAnnoPF=ag$datAnnoPF,outPF=ag$outPF,rawP=ag$rawP)


