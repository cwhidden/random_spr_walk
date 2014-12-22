args <- commandArgs(trailingOnly = TRUE)
in_file <- args[1];
out_file <- args[2];
tree_num_file <- args[3];


cls <- c(distance="numeric", curvature="numeric")
mydata <- read.csv(in_file, sep=",", colClasses=cls);

do_interesting_trees = FALSE;
if (file.exists(tree_num_file)) {
	interesting_trees <- read.csv(tree_num_file, sep=",", header = FALSE)
	do_interesting_trees = TRUE;
}

pdf(paste(out_file, ".pdf", sep=""));

require(ggplot2)
require(scales)
require(reshape)
require(plyr)

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

p <- ggplot(mydata, aes(x = MCT)) +
	geom_density()
print(p);

p <- ggplot(mydata, aes(x = num1, y = num2)) +
	geom_tile(aes(fill = MCT), colour = "white") +
	scale_fill_gradient(low = "white", high="steelblue") +
	xlab("tree 1") +
	ylab("tree 2")
print(p);

p <- ggplot(mydata, aes(x = num1, y = num2)) +
	geom_tile(aes(fill = MAT), colour = "white") +
	scale_fill_gradient(low = "white", high="steelblue") +
	xlab("tree 1") +
	ylab("tree 2")
print(p);

if (do_interesting_trees) {

mydata_subset = subset(mydata,
		mydata$num1 %in% interesting_trees$V1 &
		mydata$num2 %in% interesting_trees$V1)

mydata_subset$num1=as.factor(mydata_subset$num1)
mydata_subset$num2=as.factor(mydata_subset$num2)

p <- ggplot(mydata_subset, aes(x = num1, y = num2)) +
	geom_tile(aes(fill = MCT), colour = "white") +
	scale_fill_gradient(low = "white", high="steelblue") +
	xlab("tree 1") +
	ylab("tree 2") +
	ggtitle("MCT (most likely trees)");
print(p)

p <- ggplot(mydata_subset, aes(x = num1, y = num2)) +
	geom_tile(aes(fill = MAT), colour = "white") +
	scale_fill_gradient(low = "white", high="steelblue") +
	xlab("tree 1") +
	ylab("tree 2") +
	ggtitle("MAT (most likely trees)");
print(p);

}
	
dev.off()
quit()
