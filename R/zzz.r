.onLoad <- function(libname, pkgname) {
  op <- options()
  op.anno <- list(
    anno.ptsPerGrp = 250000, #default annotation group size
    anno.annoSuffix = '_anno', #default suffix for annotated file
    anno.geeSuffix = '_foree', #default suffix for annotated file
    anno.rawP = 'raw'
  )
  toset <- !(names(op.anno) %in% names(op))
  if(any(toset)) options(op.anno[toset])

  invisible()
}
