#' Get entrez gene identifiers for a set of UniProt ids
#'
# @importFrom AnnotationDbi toTable
#' @export
getEntrezIds <- function(organism=9606,ids) {
  organisms <- list('9606'='org.Hs.eg.db','10090'='org.Mm.eg.db','10116'='org.Rn.eg.db','7227'='org.Dm.eg.db','4932'='org.Sc.sgd.db')
  if (! as.character(organism) %in% names(organisms)) {
    return()
  }
  dbname<-organisms[[as.character(organism)]]
  getBiocLiteLib(dbname)
  uprotmap <- sub("\\.db","UNIPROT",dbname)
  uprots <- unique(intersect(  toupper(ids),AnnotationDbi::mappedRkeys(get(uprotmap,asNamespace(dbname)))))
  entrez_ids <- removeFactors(AnnotationDbi::toTable(revmap(get(uprotmap,asNamespace(dbname)))[  uprots ]))
  if ("systematic_name" %in% names(entrez_ids)) {
    entrez_ids <- subset(merge(entrez_ids,removeFactors(AnnotationDbi::toTable(get(sub("\\.db","ENTREZID",dbname),asNamespace(dbname))[]) ) ,by='systematic_name'),select=c('gene_id','uniprot_id'))
  }
  names(entrez_ids) <- c('gene_id','uniprot')
  gene_ids <- entrez_ids$gene_id
  names(gene_ids) <- entrez_ids$uniprot
  return (gene_ids)
}

#' Get Gene names for a set of UniProt identifiers
#'
#' @export
getGeneNames <- function(organism=9606,ids) {
  organisms <- list('9606'='org.Hs.eg.db','10090'='org.Mm.eg.db','10116'='org.Rn.eg.db','7227'='org.Dm.eg.db','4932'='org.Sc.sgd.db')
  dbname<-organisms[[as.character(organism)]]
  getBiocLiteLib(dbname)
  library(dbname,character.only=TRUE)
  wanted_cols <- c('UNIPROT', 'SYMBOL' )
  if (as.character(organism) == '4932') {
    wanted_cols <- c('UNIPROT','GENENAME')
  }
  ids <- toupper(ids)
  mapped_ids <- intersect( ids , AnnotationDbi::keys( get(dbname,asNamespace(dbname)), 'UNIPROT' ) )
  mapping <- NULL
  if (length(mapped_ids) > 0) {
    mapping <- AnnotationDbi::select(get(dbname,asNamespace(dbname)), keys=mapped_ids, columns=wanted_cols, keytype="UNIPROT")
    names(mapping) <- c('uniprot','symbol')
  }
  mapping <- rbind(mapping, data.frame(uniprot=ids[ ! ids %in% mapped_ids ],symbol=ids[ ! ids %in% mapped_ids  ]))
  return (mapping)
}


#' Convert entrez ids to a data frame of uniprot, genename and entrez id
#'
# @importFrom AnnotationDbi select
#' @export
convertEntrezIds <- function(organism=9606,ids=c()) {
  organisms <- list('9606'='org.Hs.eg.db','10090'='org.Mm.eg.db','10116'='org.Rn.eg.db','7227'='org.Dm.eg.db','4932'='org.Sc.sgd.db')
  dbname<-organisms[[as.character(organism)]]
  getBiocLiteLib(dbname)
  library(dbname,character.only=TRUE)
  if (length(ids) < 1) {
    return( data.frame(geneid=NA,uniprot=NA,genename=NA)[numeric(0),] )
  }
  wanted_cols <- c('UNIPROT', 'SYMBOL', 'ENTREZID')
  if (as.character(organism) == '4932') {
    wanted_cols <- c('UNIPROT', 'GENENAME', 'ENTREZID')
  }
  retdata <- AnnotationDbi::select(get(dbname,asNamespace(dbname)), keys=as.character(ids), columns=wanted_cols, keytype="ENTREZID")
  names(retdata) <- c('geneid','uniprot','genename')
  retdata
}