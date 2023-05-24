library(BSgenome.Hsapiens.UCSC.hg38)
library(plyranges)
library(tidyverse)
library(magrittr)


WIN_SIZE = 205
EPSILON = 30
TPM = 5

FILE_UTROME = sprintf("data/granges/utrome_gr_txs.e%d.t%d.gc39.pas3.f0.9999.w500.Rds", EPSILON, TPM)
FILE_BED = sprintf("data/bed/celltypes/celltypes.e%d.t%d.bed.gz", EPSILON, TPM)

CSV_OUT = sprintf("data/seq/utrome_cleavage_sites.e%d.t%d.gc39.w%d.csv.gz", EPSILON, TPM, WIN_SIZE)

## load cleavage sites
gr_sites <- read_bed(FILE_BED) %>% 
    `seqlevelsStyle<-`("UCSC") %>%
    keepStandardChromosomes(pruning.mode="coarse") %>%
    anchor_center() %>%
    mutate(width=EPSILON)

## Load all transcripts
gr_txs <- readRDS(FILE_UTROME)

## focus on cleavage sites
gr_cleavage <- gr_txs %>%
    anchor_3p %>%
    mutate(n_celltypes=count_overlaps_directed(mutate(., width=0), gr_sites)) %>%
    mutate(width=WIN_SIZE) %>%
    shift_downstream(WIN_SIZE/2) %>%
    mutate(origin=ifelse(is_novel, "UTRome", "GENCODE"),
           origin_ud=case_when(
               !is_novel ~ "GENCODE",
               str_detect(transcript_id, "UTR-") ~ "upstream",
               str_detect(transcript_id, "UTR+") ~ "downstream"
           ))

seqs <- getSeq(BSgenome.Hsapiens.UCSC.hg38, gr_cleavage)

df_seqs <- gr_cleavage %>% 
    as_tibble %>%
    dplyr::select(transcript_id, seqnames, strand, is_ipa, is_proximal, is_distal, 
                  utr_type, n_celltypes, origin, origin_ud) %>%
    mutate(seq=as.character(seqs))

write_csv(df_seqs, CSV_OUT)

