# Samara Image Analysis — Technical Report

## 1. Scope

This report analyses the supplied MATLAB source and the two supplied plots. It does not modify the source files and does not claim experimental values that are not supported by the supplied material.

The central workflow is an image-processing approach to tracking a falling/rotating samara and extracting projected area, image-space descent/path, vertical descent velocity, rotational speed (RPM), and coning angle.

## 2. Main workflow

The main samara scripts use background subtraction to isolate the seed from a sequence of TIFF images. The first frame is used as a grayscale background, a threshold is applied, and the resulting foreground is used for area and coordinate measurements.

The newer script uses a threshold of `15`; the older variants use `10`. The newer version records foreground extrema for each frame and then derives a path, descent speed, projected-area history, RPM and coning angle.

## 3. Projected area

The **Projected Area Variation** figure plots image number against foreground area in pixels. It rises to an early maximum of roughly 4.6–4.7 thousand pixels and then shows repeated oscillations with a decreasing envelope toward the end of the sequence.

The repeated minima are important because the source code treats low-area local minima as candidate rotational landmarks. Their spacing is then used in the RPM calculation.

The plot alone does not establish physical area in square metres, aerodynamic forces, lift/drag, or an exact RPM.

## 4. Path tracking

The **Samara Path Tracking** figure is generated from image-coordinate measurements. It shows a predominantly descending trajectory with a long diagonal section followed by a more vertically concentrated path and smaller lateral variations.

This is best interpreted as an image-space trajectory unless the calibration factors are applied and validated.

## 5. Velocity calculation

The newer script uses:

```matlab
speed(i) = (Y(i+1)-Y(i))*0.000857*1057;
```

Older variants use `0.00082` instead of `0.000857`.

The constants are therefore experimental calibration parameters embedded in the source. Their exact units and provenance are not fully documented in the supplied material. In particular, the meaning of `1057` should be verified against the camera/frame-rate setup.

## 6. RPM calculation

The scripts detect local minima in the projected-area signal below the mean area. The frame indices of those minima are then used to estimate rotational timing.

The versions do not use identical formulas. The newer variant uses a difference between minima separated by two detected minima, while older variants use reciprocal adjacent-minimum spacing and a different multiplier. Therefore RPM results should not be assumed to be interchangeable between versions without checking the physical meaning of each detected landmark.

## 7. Coning angle

The coning-angle calculation uses top/bottom image coordinates at selected area-minimum frames and applies `atand(...)` to the coordinate differences. The newer version separates left/right cases and combines the resulting angle arrays.

This is an image-geometry estimate. Its validity depends on correct foreground identification, coordinate orientation, calibration, and correct interpretation of the selected rotational phase.

## 8. Supporting files

### `code_extract.mlx`

A separate MATLAB Live Script containing work for importing `.dat` velocity-field data, coordinate transformations, extracting velocity at selected points, plotting `u` and `v` components, and extracting velocity fields along sections.

### `grabit.m`

An image digitization/calibration utility. Its supplied header describes calibration of image axes using four points and extraction of multiple point datasets.

### `natsort.m` and `natsortfiles.m`

Natural/alphanumeric filename sorting utilities used to process numbered image files in numerical order.

### `Add_axis_to_the_image.m`

Adds a crop from an axis image to each PNG frame using fixed image coordinates and a hard-coded source path.

### `scale.tif` and the supplied video

These are supplied experimental/reference assets and should be treated as source data rather than generated results.

## 9. Implementation observations

The source contains hard-coded Windows paths, different thresholds between versions, and legacy MATLAB functions such as `im2bw`. Some variants also call `flipud(I1);` without assigning its result and contain path constructions that should be checked for consistency between `files` and `files3`.

These are observations only; the original source was not edited.

## 10. Recommended validation

1. Confirm the camera frame rate and the meaning of `1057`.
2. Document the pixel-to-metre calibration factors.
3. Verify that the first frame is an appropriate background.
4. Test threshold sensitivity.
5. Overlay detected coordinates on sample masks.
6. Confirm how many rotational events correspond to each area minimum.
7. Compare RPM with an independent measurement if available.
8. Validate the coning-angle geometry on representative frames.
9. Record the MATLAB release and required toolboxes.
10. Replace machine-specific paths with configuration variables only in a future cleaned-up version; the supplied files themselves should remain preserved.

## 11. Conclusion

The supplied project forms an image-based experimental workflow for a rotating/falling samara: isolate the seed, measure projected area and image coordinates, and use those signals to infer descent, rotation, and coning behaviour. The strongest directly visible result is the oscillatory projected-area signal coupled with a descending image-space trajectory. Quantitative velocity, RPM, and coning results remain calibration-dependent until the constants, timing, coordinate conventions, and landmark assumptions are independently verified.
