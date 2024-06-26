rm(list=ls())
install.packages("FITSio")
require("FITSio")

cB58 = readFrameFromFITS(args[1],header=TRUE)
n_cB58 = length(cB58)
files = list.files(args[2])
n.files = length(files)

distance = function(A, B) {
  return(sqrt(sum((A - B)^2)))
}


for (i in 1:n.files) {
  path = paste(sep="", "D:\\写作业\\1\\data\\data\\", files[i])
  # cat(sep="", "path=", path, "\n")
  noisy = readFrameFromFITS(path)
  
  n_noisy = length(noisy$flux)
  
  # cat(sep="", "n_cB58=", n_cB58, ", n_noisy=", n_noisy, "\n")
  
  min_d = 1000000
  best_j = 10
  for (j in 1:(n_noisy - n_cB58)) {
    slice = noisy$flux[j:(j + n_cB58)]
    ##print(str(slice))
    d = distance(cB58$FLUX, slice)
    if (is.na(d)) {
      # cat(sep="", "NA at j=", j, "\n")
    }
    if (d < min_d) {
      min_d = d
      best_j = j
    }
    # cat(sep="", "j=", j, ", d=", d, ", best_j=", best_j, ", min_d=", min_d, "\n")
  }
  cat(sep=",",min_d,files[i],best_j,"\n")
}

