library(grid)
library(viridis)

# use pdf as needs to be scaleable and able to be included in PDF documents
pdf("inst/extdata/assets/magma_border.pdf", width = 1, height = 10)
grid.newpage()
grid.raster(rev(magma(10)))
dev.off()
