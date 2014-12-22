args <- commandArgs(trailingOnly = TRUE)
in_file <- args[1];
out_file <- args[2];

cls <- c(distance="numeric", curvature="numeric")
mydata <- read.csv(in_file, sep=",", colClasses=cls);

pdf(paste(out_file, ".pdf", sep=""));

require(ggplot2)
require(scales)

theme_set(theme_bw(16) +
	theme(strip.background=element_blank(),
		legend.text=element_text(size=10),
		legend.title=element_text(size=10),
		legend.key=element_blank(),
		axis.text=element_text(size=10)
	))



#mydata = subset(mydata, !is.na(mydata$MCT) & mydata$distance > 0)
mydata = subset(mydata, !is.na(mydata$MCT))

limits <- aes(ymax = MCT + MCTERR, ymin = MCT - MCTERR)


#p <- ggplot(mydata, aes(x = curvature, y = MCT, color=factor(distance)))
#p + geom_point(size=2) +
#		geom_errorbar(limits)

p <- ggplot(mydata, aes(x = MCT))
p + geom_density()

dev.off()
quit()
