module load R/R-3.4.4

RpackagesDir="R/library"
mkdir --parents "$RpackagesDir"

Rscript q2_install_run.R "$RpackagesDir"

tar -oxf data.tar data;


cb5="cB58_Lyman_break.fit"
data="./data/"
Rscript hw4.R "$cb5" "$data"
