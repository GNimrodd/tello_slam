#include <iostream>
#include <opencv/highgui.h>
#include "live_slam_wrapper.h"
#include <opencv2/imgproc.hpp>
#include "util/settings.h"
#include "util/global_funcs.h"
#include "util/undistorter.h"
#include "io_wrapper/OpenCVImageStreamThread.h"
#include "slam_system.h"
#include "DebugOutput3DWrapper.h"

using namespace std;
using namespace lsd_slam;


int main(int argc, char **argv) {
  
    std::string cam_device(argv[1]);
    std::string calibration_filepath(argv[2]);

    cv::VideoCapture capture(cam_device);

    if (!capture.isOpened()) {
        printf("capture is null\n");
        exit(1);
    }

    OpenCVImageStreamThread *inputStream = new OpenCVImageStreamThread();
    inputStream->setCalibration(calibration_filepath);
    inputStream->setCameraCapture(&capture);
    inputStream->run();
    Output3DWrapper *outputWrapper = new DebugOutput3DWrapper(
            inputStream->width(), inputStream->height());
    LiveSLAMWrapper slamNode(inputStream, outputWrapper);
    cv::Mat frame;
    capture >> frame;

    cv::Mat mymat(frame);

    // cv::circle(mymat, cv::Point(100, 100), 20, cv::Scalar(255, 1, 0), 5);

    slamNode.Loop();

    Undistorter *undistorter = Undistorter::getUndistorterForFile(calibration_filepath.c_str());
    int i = 0;
    while (true) { //Create infinte loop for live streaming
        capture >> frame;
        TimestampedMat bufferItem;
        bufferItem.timestamp = Timestamp::now();
        mymat = cv::Mat(frame, true);
        printf("%d\n", i++);

        undistorter->undistort(frame, mymat);

        cv::imshow("Camera_Output", frame); //Show image frames on created window
        cv::imshow("Camera_Output_Undist", mymat);
        char key = cvWaitKey(10); //Capture Keyboard stroke
        if (char(key) == 27) {
            break; //If you hit ESC key loop will break.
        }
    }

    if (inputStream != nullptr)
        delete inputStream;
    if (outputWrapper != nullptr)
        delete outputWrapper;

    return 0;
}
