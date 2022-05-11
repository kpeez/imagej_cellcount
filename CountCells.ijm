/*
* Macro to process multiple images for identifying cells in
*/

#@ File (label = "Input directory", style = "directory") input
//#@ String (label = "Image type", value = ".png") suffix
#@ String (label = "Channel color (lowercase)", value = "red") ch_color
#@ Float (label="Enhance contrast", value = 0.35) contrast_enhance
#@ Integer (label="Outlier radius", value = 6) outlier_radius
#@ Integer (label="Outlier threshold", value = 30) outlier_threshold
#@ Integer (label="Gaussian Median filter radius", value = 3) median_filter_radius
#@ Integer (label="Prominence (Find Maxima)", value = 35) maxima_prominence
	
processFolder(input, outlier_radius, outlier_threshold, median_filter_radius, maxima_prominence);
	
// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input, outlier_radius, outlier_threshold, median_filter_radius, maxima_prominence) {
	//	set up params
	suffix = ".png";
	list = getFileList(input);
	count_path = File.getParent(input) + "/counts/";
	label_path = File.getParent(input) + "/labels/";
	//	Create ./counts/ and ./labels/ dirs if they don't exist
	if(File.isDirectory(count_path) == 0) {
		File.makeDirectory(count_path);
	}
	if(File.isDirectory(label_path) == 0) {
		File.makeDirectory(label_path);
	}
	for (i = 0; i < list.length; i++) {
		img_file = input + File.separator + list[i];
		if(File.isDirectory(input + "/" + list[i])){
			processFolder("" + input + "/" + list[i]);
		}
		if(endsWith(list[i], suffix)){
			countImage(input, list[i], outlier_radius, outlier_threshold, median_filter_radius, maxima_prominence);
		}
	}

	// save variables as txt file inside input folder
	print("\\Clear");
	print("outlier_radius, " + outlier_radius);
	print("outlier_threshold, " + outlier_threshold);
	print("median_filter_radius, " + median_filter_radius);
	print("maxima_prominence, " + maxima_prominence);
	params_file = input + File.separator + "cell_count_params.txt";
	selectWindow("Log");
	saveAs("txt", params_file);
	print("\\Clear");
	num_images = list.length;
	print("Completed! Processed n =" + num_images + " images.");
}

function countImage(input, file, outlier_radius, outlier_threshold, median_filter_radius, maxima_prominence) {
	
	filename = File.getNameWithoutExtension(list[i]);
	count_path = File.getParent(input) + "/counts/";
	label_path = File.getParent(input) + "/labels/";
	img_file = input + File.separator + list[i];

	//	get image from channel
	open(img_file);
	run("Split Channels");
	cell_ch = list[i] + " (" + ch_color + ")";
	selectWindow(cell_ch);
	//	pre-process: enhance contrast, remove outliers, median filter
	run("Enhance Contrast", "saturated=&contrast_enhance");
	run("Remove Outliers...", "radius=&outlier_radius threshold=&outlier_threshold which=Bright");
	run("Median...", "radius=&median_filter_radius");
	//	find maxima and save list to .csv
	run("Find Maxima...", "prominence=&maxima_prominence exclude output=List");
	count_filename = count_path + filename + "_counts.csv";
	saveAs("Results", count_filename);
	print("Count data saved in " + count_filename);
	label_filename = label_path + filename + "_labels.tif";
	//	plot maxima labels and save image
	run("Find Maxima...", "prominence=&maxima_prominence exclude output=[Point Selection]");
	saveAs("tif", label_filename);
	print("Labeled image saved in " + label_filename);
	close("*");
	selectWindow("Results");
	run("Close");
}