/*
* Macro to calculate the area of a given ROI
*/
#@File(label = "Input directory", style = "directory") input
#@String(label="Brain region", value="") region
	
GetAreaROI(input);
	
// function to scan folders/subfolders/files to find files with correct suffix
function GetAreaROI(input) {
	list = getFileList(input);
	data_file = input + File.separator + region + "_ROI_area_results.csv";
	run("Set Measurements...", "area display redirect=None decimal=3");
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], ".roi")){
//			print(list[i]);
			open(input + File.separator + list[i]);
			roiManager("Add");
			roiManager("Select", 0);
			roiManager("Measure");
			roiManager("Delete");
			close();
		}
	}
	// remove duplicate filename from label (filename:label)
	for (i=0; i<nResults; i++) {
		oldLabel = getResultLabel(i);
		delimiter = indexOf(oldLabel, ":");
		// Some results have img:roi name, remove extra stuff
		if(delimiter > 0){
			new_label = substring(oldLabel, delimiter+1);
		} else {
			new_label = replace(getResultLabel(i), ".roi", "");
		}
	    setResult("Label", i, new_label);
	    }
	saveAs("Results", data_file);	
	cleanUp();
}

function cleanUp(){
	// clear and close ROI manager
   	close("*");					
	roiManager("reset"); 
	close("Roi Manager");
	// close Results window
	if (isOpen("Results")) { 
		selectWindow("Results"); 
		run("Close" );
		}
}