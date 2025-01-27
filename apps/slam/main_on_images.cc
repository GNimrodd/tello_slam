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

#include "util/undistorter.h"


std::vector<std::pair<double, std::string>> read_frame_list(const std::string &filepath) {
	std::ifstream ifs(filepath);
	if (ifs.fail()) {
		printf("Fail to read file:%s\n", filepath.c_str());
		exit(-1);
	}

	std::vector<std::pair<double, std::string>> files;
	while (!ifs.eof()) {
		double time;
		std::string fn;
		ifs >> time >> fn;
		files.emplace_back(std::make_pair(time, fn));
	}


	for (auto i = 0; i < files.size(); i++) {
		std::cout << "time = " << files[i].first << " frame_file = " << files[i].second << std::endl;
	}

	return files;
}

//apps_name calib_file frame_list
using namespace lsd_slam;
int main( int argc, char** argv )
{
	
	std::string frame_list(argv[1]);
    std::string calibFile(argv[2]);


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

	auto files = read_frame_list(frame_list);

	cv::Mat image = cv::Mat(h,w,CV_8U);
	int runningIDX=0;

	for(unsigned int i=0;i<files.size();i++)
	{
		cv::Mat imageDist = cv::imread(files[i].second, cv::ImreadModes::IMREAD_GRAYSCALE);

		if(imageDist.rows != h || imageDist.cols != w)
		{
			if(imageDist.rows * imageDist.cols == 0)
				printf("failed to load image %s! skipping.\n", files[i].second.c_str());
			else
				printf("image %s has wrong dimensions - expecting %d x %d, found %d x %d. Skipping.\n",
						files[i].second.c_str(),
						w,h,imageDist.cols, imageDist.rows);
			continue;
		}
		assert(imageDist.type() == CV_8U);

		undistorter->undistort(imageDist, image);
		assert(image.type() == CV_8U);

		if(runningIDX == 0)
			system->randomInit(image.data, files[i].first, runningIDX);
		else
			system->trackFrame(image.data, runningIDX , false,files[i].first);
		runningIDX++;
	}

	system->finalize();

	delete system;
	delete undistorter;
	delete outputWrapper;
	return 0;
}
