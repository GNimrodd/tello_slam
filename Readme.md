# LSD SLAM without ROS, updated to work on ubuntu 19

Original project: https://github.com/aivijay/lsd_slam_noros

## Installation
1. Download all relevant libraries listed in the original project
2. replace thirdparty/eigen-3.2.1 with a link to the eigen library you installed in (1) \[keep the name]

Hit make.
The results are three executables:
1. sample_app: a live slam application. Call it with a device name and a path to a configuration file
2. main_on_images: an offline slam application. Call it with a path to a file with the frame list, and a path to a configuration file

The frame list file is mulitple rows in the form:
<timestamp>	<path_to_image>

3. live_main: another live application, with a slightly different implementation. Use the same as (1)

## configuration file
An XML file of the form:
<?xml version="1.0"?>
<opencv_storage>
    <image_Width>960</image_Width>
    <image_Height>720</image_Height>
    <Camera_Matrix type_id="opencv-matrix">
        <rows>3</rows>
        <cols>3</cols>
        <dt>d</dt>
        <data>
            925.8457 1.9141 465.5455 0.0 920.8599 375.7772 0.0 0.0 1.0
        </data>
    </Camera_Matrix>
    <Distortion_Coefficients type_id="opencv-matrix">
        <rows>5</rows>
        <cols>1</cols>
        <dt>d</dt>
        <data>
            0.0 0.0 0.0 0.0 0.0
        </data>
    </Distortion_Coefficients>
</opencv_storage>
