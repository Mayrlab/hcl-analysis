library(BSgenome.Hsapiens.UCSC.hg38)
library(plyranges)
library(tidyverse)
library(magrittr)


WIN_SIZE = 205
EPSILON = 30
TPM = 5

FILE_BED = sprintf("data/bed/celltypes/celltypes.e%d.t%d.bed.gz", EPSILON, TPM)
FILE_BED_UNLIKELY = sprintf("data/bed/cleavage-sites/utrome.unlikely.e%d.t%d.gc39.pas3.f0.9999.bed.gz",
                            EPSILON, TPM)
CSV_OUT = sprintf("data/seq/likely_ip_sites.e%d.t%d.gc39.w%d.csv.gz", EPSILON, TPM, WIN_SIZE)

## load cleavage sites
gr_sites <- read_bed(FILE_BED) %>% 
    `seqlevelsStyle<-`("UCSC") %>%
    keepStandardChromosomes(pruning.mode="coarse") %>%
    anchor_center() %>%
    mutate(width=EPSILON)

## focus on cleavage sites
gr_ip <- read_bed(FILE_BED_UNLIKELY) %>%
    `seqlevelsStyle<-`("UCSC") %>%
    anchor_3p %>%
    mutate(n_celltypes=count_overlaps_directed(mutate(., width=0), gr_sites)) %>%
    mutate(width=WIN_SIZE) %>%
    shift_downstream(WIN_SIZE/2)

seqs <- getSeq(BSgenome.Hsapiens.UCSC.hg38, gr_ip)

df_seqs <- gr_ip %>% 
    as_tibble %>%
    dplyr::select(name, seqnames, strand, n_celltypes) %>%
    mutate(seq=as.character(seqs))

write_csv(df_seqs, CSV_OUT)

