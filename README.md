# ImageJ Macros for cell quantification

Macro-based method for semi-automated cell quantification of single-plane images in [ImageJ](https://imagej.net/).

## Setting up the data

Your directory should have the following structure (within the region folder)

```ascii
expeirment_folder/
├── data/
    └── images/
        └── region/
            ├── region_1/
            │   ├── png-files
            │   ├── roi-images
            │   └── roi-data
            ├── region_2/
            │   └── ...
            └── ...
```

Where:

- `png-files`: directory containing all of the raw (or merged) color images
- `roi-images`: directory where user-curated ROI images will be saved.
- `roi-data`: directory containing an .roi file for each image
  - this is used to calculate the area of each ROI (in pixels)

## Analysis Pipeline

<img src="docs/cell_count_schematic.png" title="Overview of analysis pipeline">

Steps:

1. User defines ROIs and saves ROI images with `SaveROI.ijm`.
2. Once ROIs are drawn, run `CountCells.ijm` to quantify cells.
   - First, image contrast is enhanced.
   - Next, outlier pixels are removed (useful for images with small bright spots that can be mis-identified as cells).
   - A Gaussian blur filter is applied to the image
   - Find maxima is used to identify spots
3. Run `GetAreaROI.ijm` to get the area (in pixels) of the ROI assocaited with each image.
   - Note: The conversion factor from pixels -> µm will depend on your microscope.

## SaveROI

(Note: If the `roi-images` and `roi-data` folders are not there they will be created automatically when running SaveROI)

This macro is used to help speed up the user-curated creation of ROIs containing cells to quantify. In order to use it you must install it each time you open ImageJ/FIJI (Plugins > Macros > Install). It is recommended to next specify a keyboard shortcut for easier use (e.g., I use F1).

To use:

1. Select an area on the image using one of the selection tools -- polygon is suggested for most flexibility but rectangle or oval can also be used.
2. Clear the area outside of the ROI selection with  `Edit > Clear Outside`
   - For batch processing of images I suggest creating a keyboard shortcut to save time (e.g., I use F2).

- The new ROI will be saved in roi-images as `filename_ROI.png`.
- The ROI data will saved in roi-data as `filename.roi`.
- **Note:** Make sure the type of images you are processing is correctly set in the `image_type` parameter (e.g., "png", "tiff")

## GetAreaROI

Now that you have a directory of .roi files associated with each image, you can use this macro to generate a .csv file containing each image in one column (Label) as well the area (in pixels) of the ROI for that image. All you need to do to run this macro is either:

1. Double-click the GetAreaROI.ijm file to open it in the ImageJ edit > select Run and use the pop-up menu to select the `roi-data` folder you want to analyze.
2. Install in ImageJ and run the macro. Again you will then use the pop-up menu to select the `roi-data` folder you want to analyze.

## CountCells

NOTE: This macro will likely require you to test different parameter values until you find a set of parameters that gives you reliable labeling.

### Parameters

See [ImageJ process docs](https://imagej.nih.gov/ij/docs/menus/process.html) for more info.

- `Input directory`: directory containing the user-drawn ROI images.
- `Channel color`: Specify color containing cells of interest (for RGB images).
- `Enhance contrast`: Enhances image contrast by using either histogram stretching or histogram equalization.
- `Outlier radius` and `Outlier threshold`: arguments for the `Remove Outliers` step. This step replaces a pixel by the median of the pixels in the surrounding area (`Outlier radius`) if it deviates from the median by more than the `Outlier threshold`. Useful for correcting small bright spots in images.
- `Gaussian Median filter radius`: The size of the radius used when applying the Gaussian Blur function for smoothing.
- `Prominence (Find Maxima)`: Finds local maxima in the image that "stand out" from the surrounding by the given prominence value.

### Using the macro

1. Double-click the CountCells.ijm and select Run.
2. Select the `Input directory` -- this is the `roi-images` folder containing user-defined ROI images from the `SaveROI` macro.
3. Next, enter the parameter values in each field and click OK.
4. Once the program starts, it will load each file in `roi-images`, apply the processing steps (Outlier removal > Median filter > Find Maxima) on each image.
   - An image (`filename_ROI_labels.tif`) containing labels for each identified cell will be created in the `./labels` folder.
   - A `filename_ROI_counts.csv` file contaning the X and Y coordinates of each detected cell will be created in the `./counts` folder.
   - A `cell_count_params.txt` file will be saved in the input folder containing the values used to quantify the images.

## Additional analyses

- Now that you have a file containing the coordinates of identified cells in each ROI, and the area of the ROI, you can analyze these .csv files in python, R, etc.
- Counts should be normalized in some way in order to avoid spurious results.
  - e.g. counts can be normalized by dividing the # cells by the ROI area. If you have a separate cell marker (e.g., DAPI) you can quantify the cells in that channel.
- In order to make sure the counts from each ROI are accurate it is suggested that you normalize the counts by dividng the # of cells in an ROI with the size of the ROI.
