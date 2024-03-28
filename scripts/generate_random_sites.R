library(BSgenome.Hsapiens.UCSC.hg38)
library(plyranges)
library(tidyverse)
library(magrittr)

set.seed(20230616)
WIN_SIZE=205L
PADDING=ceiling(WIN_SIZE/2)
N_SAMPLES=10000L
RAW_SAMPLES=N_SAMPLES*1.1

CSV_OUT = sprintf("data/seq/random.205.csv.gz")

genome <- BSgenome.Hsapiens.UCSC.hg38

idx_chrs <- str_c("chr", c(1:22,"X", "Y"))

# Get the total genome length
chrom_sizes <- seqlengths(genome)[idx_chrs]

# Generate 10,000 random positions across the whole genome
chrom_random <- sample(names(chrom_sizes), size=RAW_SAMPLES, prob=chrom_sizes, replace=TRUE)
chrom_random %<>% sort()

n_pos <- table(chrom_random) %>% { setNames(as.numeric(.), names(.)) }

pos_random <- integer()
for (i in seq_along(n_pos)) {
    pos_random <- c(pos_random, sample((1+PADDING):(chrom_sizes[names(n_pos)[i]] - PADDING), n_pos[i], replace=FALSE))
}

strand_random <- sample(c("-", "+"), size=RAW_SAMPLES, replace=TRUE)


## create GR
gr_rand <- tibble(seqnames=chrom_random, 
                  start=pos_random, end=pos_random, 
                  strand=strand_random) %>%
    as_granges() %>%
    `seqlevelsStyle<-`("UCSC") %>%
    anchor_center %>%
    mutate(width=WIN_SIZE)


seqs <- getSeq(genome, gr_rand)

idx_clean <- which(Biostrings::letterFrequency(seqs, "N") == 0) %>% 
    sample(size=N_SAMPLES, replace=FALSE)

df_seqs <- gr_rand[idx_clean,] %>% 
    as_tibble %>%
    mutate(name=str_c("random_", 1:n()), n_celltypes=0) %>%
    dplyr::select(name, seqnames, strand, n_celltypes) %>%
    mutate(seq=as.character(seqs[idx_clean,])) %>%
    arrange()

write_csv(df_seqs, CSV_OUT)

gr_rand[idx_clean,] %>%
    mutate(width=1) %>%
    mutate(name=str_c("random_", 1:length(.))) %>%
    write_bed("data/bed/random_sites.bed")


