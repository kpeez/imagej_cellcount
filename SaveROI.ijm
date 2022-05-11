/*
Macro to process ROIs
*/
image_type = "tiff"

function save_roi_data() {
//	rename ROI in ROI Mananger and save .roi file
	roi_file_name = replace(getTitle(), image_type, "roi");
	roi_image_name = replace(getTitle(), "."+image_type, "_ROI.png");
	file_dir = getDirectory("image");
	roi_data_dir = File.getParent(file_dir) + "/roi-data/";
	roi_image_dir = File.getParent(file_dir) + "/roi-images/";
	
	
	//	Create ./roi-data/ and ./roi-images/ dirs if they don't exist
	if(File.isDirectory(roi_data_dir) == 0) {
		File.makeDirectory(roi_data_dir);
	}
	if(File.isDirectory(roi_image_dir) == 0) {
		File.makeDirectory(roi_image_dir);
	}
	
	// Save ROI data
	roiManager("add");
	roiManager("select", 0);
	roiManager("rename", roi_file_name);
	run("Clear Outside");
	
	// save ROI image and ROI data
	saveAs("PNG", roi_image_dir + roi_image_name);
	roiManager("Save Selected", roi_data_dir + roi_file_name);
	
	print("ROI data successfully saved in the following location:");
	print("ROI data:" + roi_data_dir + roi_file_name);
	print("ROI image:" + roi_image_dir + roi_image_name);


	roiManager("Reset");
	close();
}

macro "CreateROI [F1]" {
    save_roi_data()
}