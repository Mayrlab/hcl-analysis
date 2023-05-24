library(tidyverse)
library(writexl)
library(magrittr)

FILE_IN="data/annots/hcl_cell_annots.clean.tsv.gz"
FILE_OUT="data/annots/counts_celltype_batch_hcl.xlsx"
MIN_FRAC=0.1

df_annots <- read_tsv(FILE_IN)

df_celltypes <- df_annots %>%
    dplyr::count(cluster, cell_type, batch, name="n_cells") %>%
    mutate(celltype_id=str_c(cluster, "-", cell_type),
           cell_type=NULL) %>%
    pivot_wider(id_cols=c("celltype_id", "cluster"), 
                names_from="batch", 
                values_from="n_cells", values_fill=0)

mat_ct_tissue <- df_celltypes %>%
    mutate(cluster=NULL) %>%
    column_to_rownames("celltype_id") %>%
    as.matrix()

## compute top tissues per celltype
top_tissues <- mat_ct_tissue %>%
    ## normalize by row and test
    { (. / rowSums(.)) >= MIN_FRAC } %>%
    {
        ## detect tissues by celltype
        idxs_tissues <- apply(., 1, which)
        
        ## for each celltype
        names(idxs_tissues) %>%
            ## convert back to raw counts
            lapply(function (x) { mat_ct_tissue[x, idxs_tissues[[x]], drop=FALSE]}) %>%
            ## convert entries to named vectors
            lapply(function (x) { setNames(as.vector(x), dimnames(x)[[2]]) }) %>%
            ## sort by cells, then concat names
            sapply(function (x) { str_c(names(sort(x, decreasing=TRUE)), collapse=";") }) %>%
            ## reattach celltypes
            `names<-`(names(idxs_tissues))
    }

df_celltypes %>%
    ## attach top tissues
    mutate(tissues=top_tissues[celltype_id]) %>%
    ## sort tissues alphabetically
    select(order(colnames(.))) %>%
    ## put metadata first
    select(celltype_id, cluster, tissues, everything()) %>%
    ## write
    write_xlsx(FILE_OUT)


