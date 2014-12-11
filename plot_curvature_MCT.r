args <- commandArgs(trailingOnly = TRUE)
in_file <- args[1];
out_file <- args[2];

cls <- c(distance="numeric", curvature="numeric")
mydata <- read.csv(in_file, sep="", colClasses=cls);

pdf(paste(out_file, ".pdf", sep=""));

require(ggplot2)
require(scales)

#mydata$data <- factor(mydata$data,
#		levels = c("DS1", "DS2", "DS3", "DS4", "DS5", "DS6", "DS7", "DS8", "DS9", "DS10", "DS11"))

# example data
#num1 num2 tree1 tree2 distance curvature MAT MCT
#0 0 (((((1,2),3),4),5),6); (((((1,2),3),4),5),6); 0 - 942.703464529812 1885.40692905962
#31 31 (((1,2),(3,5)),(4,6)); (((1,2),(3,5)),(4,6)); 0 - 946.137950610279 1892.27590122056

theme_set(theme_bw(16) +
	theme(strip.background=element_blank(),
		legend.text=element_text(size=10),
		legend.title=element_text(size=10),
		legend.key=element_blank(),
#		legend.position="bottom",
		axis.text=element_text(size=10)
#		panel.grid.major.x=element_line(size=1)
	))



length(mydata$num1)
tail(mydata)
#mydata = subset(subset(mydata, mydata$MAT != NA), mydata$distance > 4)
mydata = subset(mydata, !is.na(mydata$MCT) & mydata$distance > 0)
length(mydata$num1)
tail(mydata)

limits <- aes(ymax = MCT + MCTERR, ymin = MCT - MCTERR)


#p <- ggplot(mydata, aes(x = log10(scaled_iterations), y = gRMSD, shape = factor(runs), color = factor(chains)))
p <- ggplot(mydata, aes(x = curvature, y = MCT, color=factor(distance)))
p + geom_point(size=2, alpha=0.5) #+
#	facet_grid(distance ~ .)

p <- ggplot(mydata, aes(x = curvature, y = MCT, color=factor(distance)))
p + geom_point(size=2) +
		geom_errorbar(limits)

p <- ggplot(mydata, aes(x = MCT, color=factor(distance)))
p + geom_density() #+
#		geom_density(color="grey")

dev.off()
quit()
