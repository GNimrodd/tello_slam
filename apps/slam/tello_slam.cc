#include <iostream>
#include <cv.h>
#include <highgui.h>
#include <opencv2/videoio.hpp>
#include "live_slam_wrapper.h"

#include "util/settings.h"
#include "util/global_funcs.h"

#include "util/undistorter.h"
#include "io_wrapper/OpenCVImageStreamThread.h"
#include "slam_system.h"
#include "DebugOutput3DWrapper.h"
#include <boost/python.hpp>

using namespace lsd_slam;

// run_lsd_slam(drone.get_udp_address(), "...")
int run_lsd_slam(const std::string &udp_address, const std::string &calib_file, const std::string &unidistorter_file) {
    cv::VideoCapture capture(udp_address);
    if (!capture.isOpened()) {
        printf("Couldn't capture video, terminating...\n");
        return -1;
    }
    OpenCVImageStreamThread *inputStream = new OpenCVImageStreamThread();
    inputStream->setCalibration(calib_file);
    inputStream->setCameraCapture(&capture);
    inputStream->run();

    Output3DWrapper *outputWrapper = new DebugOutput3DWrapper(inputStream.width(), inputStream.height());
    LiveSLAMWrapper slamNode(inputStream, outputWrapper);

    slamNode.Loop();
    Undistorter *undistorter = Undistorter::getUndistorterForFile(unidistorter_file);

    cv::Mat frame;
    while (true) { //Create infinte loop for live streaming
        capture >> frame;
        TimestampedMat bufferItem;
        bufferItem.timestamp = Timestamp::now();

        cv::Mat mymat = cv::Mat(frame, true);

        undistorter->undistort(frame, mymat);

        cvShowImage("Camera_Output", frame); //Show image frames on created window
        cv::imshow("Camera_Output_Undist", mymat);
        if (cvWaitKey(10) == 27) {
            break; //If you hit ESC key loop will break.
        }
    }

    if (inputStream)
        delete inputStream;
    if (outputWrapper)
        delete outputWrapper;

    return 0;
}

BOOST_PYTHON_MODULE(lsd_slam) {
    def("run_lsd_slam", run_lsd_slam);
}