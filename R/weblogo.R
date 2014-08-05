#' @export
generateLogoPlot <- function(dataframe,windowcol,frequencies=c()) {
  uniprot_2013_12_freq <- list(A=0.0825,R=0.0553,N=0.0406,D=0.0545,C=0.0137,Q=0.0393,E=0.0675,G=0.0707,H=0.0227,I=0.0595,L=0.0966,K=0.0584,M=0.0242,F=0.0386,P=0.0470,S=0.0657,T=0.0534,W=0.0108,Y=0.0292,V=0.0686)
  if(length(frequencies) < 1) {
    frequencies <- uniprot_2013_12_freq
  }
  pwm <- calculatePWM(dataframe,windowcol,names(frequencies))
  return(berrylogo(pwm,frequencies))
}

calculatePWM <- function(dataframe,windowcol,codes=c('A','C', 'D','E','F','G','H','I','J','K','L','M','N','P','Q','R','S','T','V','W','Y','Z')) {
  aas <- t(data.matrix(apply(as.array(dataframe[[windowcol]]),1,FUN=function(x) { unlist(strsplit(x,''))})))
  freqs <- apply(aas,2,function(x) { table(x) })
  sapply(1:dim(aas)[2],function(pos) {
    pos_freqs <- freqs[[pos]];
    total <- sum(pos_freqs)
    sapply(codes,function(aa) {
      if (! aa %in% names(pos_freqs) ) {
        return (0)
      }
      val <- pos_freqs[names(pos_freqs) == aa]
      if ( ! is.null(val) ) {
        return(as.integer(val) / total)
      }
    });
  })
}


#' @importFrom plyr laply
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 geom_line
#' @importFrom ggplot2 geom_text
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 scale_x_continuous
#' @importFrom ggplot2 coord_trans
#' @importFrom ggplot2 theme_bw
berrylogo<-function(pwm,backFreq,zero=.0001){
  pwm[pwm==0]<-zero
  bval <- plyr::laply(names(backFreq),function(x) {  pwm[x,] / backFreq[[x]] })
  row.names(bval)<-names(backFreq)
  hydrophobicity <- c(rep('#0000ff',6),rep('#00ff66',6),rep('#000000',8))
  names(hydrophobicity) <-  unlist(strsplit('RKDENQSGHTAPYVMCLFIW',''))
  chemistry <- c(rep('#00ff66',7),rep('#0000ff',3),rep('#ff0000',2),rep('#000000',8))
  names(chemistry) <- unlist(strsplit('GSTYCQNKRHDEAVLIPWFM',''))
  bval <- bval[names(hydrophobicity),]
  window_size = floor( 0.5*length(dimnames(bval)[[2]]) )
  dimnames(bval)[[2]]<- c((-1*window_size):window_size)
  p<-ggplot2::ggplot(reshape2::melt(bval,varnames=c("aa","pos")),ggplot2::aes(x=pos,y=value,label=aa))+
    ggplot2::geom_line(ggplot2::aes(y=1), colour = "grey",size=2)+
    ggplot2::geom_text(ggplot2::aes(colour=factor(aa)),face='bold',size=8)+scale_colour_manual(values=chemistry)+
    ggplot2::theme(legend.position="none")+
    ggplot2::scale_x_continuous(name="Position",breaks=(-1*window_size):window_size)+
    ggplot2::scale_y_continuous(name="Relative frequency",breaks=c(0.0625,0.125,0.25,0.5,1,seq(2,20,by=2)),limits=c(2^-11,20),label=function(x) format(x,nsmall = 2,drop0trailing=T,scientific = FALSE))+
    ggplot2::coord_trans(y='log2')+
    ggplot2::theme_bw()
  return(p)
}