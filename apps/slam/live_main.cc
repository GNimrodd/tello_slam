#include "live_slam_wrapper.h" //
#include <boost/thread.hpp> //?
#include "util/settings.h" //
#include "util/global_funcs.h" //
#include "slam_system.h" //
#include <sstream> //
#include <fstream> //
#include <dirent.h> // ?
#include <algorithm> //
#include "DebugOutput3DWrapper.h" //
#include <opencv2/imgproc.hpp> //
#include <opencv/highgui.h>
#include "util/undistorter.h"


using namespace lsd_slam;
int main( int argc, char** argv )
{
	
	std::string camdevice(argv[1]);
    std::string calibFile(argv[2]);

	cv::VideoCapture capture(camdevice);

    if (!capture.isOpened()) {
        printf("capture is null\n");
        exit(1);
    } else {
        printf("capturing video\n");
    }

    Undistorter* undistorter = Undistorter::getUndistorterForFile(calibFile.c_str());

	if(undistorter == 0)
	{
		printf("need camera calibration file! (set using _calib:=FILE)\n");
		exit(0);
	}

	int w = undistorter->getOutputWidth();
	int h = undistorter->getOutputHeight();
	float fx = undistorter->getK().at<double>(0, 0);
	float fy = undistorter->getK().at<double>(1, 1);
	float cx = undistorter->getK().at<double>(2, 0);
	float cy = undistorter->getK().at<double>(2, 1);
	Sophus::Matrix3f K;
	K << fx, 0.0, cx, 0.0, fy, cy, 0.0, 0.0, 1.0;


	// make output wrapper. just set to zero if no output is required.
	Output3DWrapper* outputWrapper = new DebugOutput3DWrapper(960, 720); // new ROSOutput3DWrapper(w,h);


	// make slam system
	SlamSystem* system = new SlamSystem(w, h, K, doSlam);
	system->setVisualization(outputWrapper);

	cv::Mat image = cv::Mat(h,w,CV_8U);
	cv::Mat imageDist;
	for (auto runningIDX = 0; true; runningIDX++)
	{
		capture >> imageDist;
		
		undistorter->undistort(imageDist, image);

		auto ts = Timestamp::now().toSec();

		cv::imshow("Camera_Output", imageDist); //Show image frames on created window
        cv::imshow("Camera_Output_Undist", image);
        char key = cvWaitKey(10); //Capture Keyboard stroke
        if (char(key) == 27) {
            break; //If you hit ESC key loop will break.
        }
		if(runningIDX == 0)
			system->randomInit(image.data, ts, runningIDX);
		else
			system->trackFrame(image.data, runningIDX , true, ts);
		runningIDX++;

		
	}

	system->finalize();

	delete system;
	delete undistorter;
	delete outputWrapper;
	return 0;
}
