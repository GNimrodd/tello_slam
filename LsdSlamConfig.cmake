get_filename_component(Closure_CONFIG_PATH "${CMAKE_CURRENT_LIST_FILE}" PATH)
set(CMAKE_MODULE_PATH  "${Closure_CONFIG_PATH}")
get_filename_component(Closure_ROOT "${Closure_CONFIG_PATH}/.." ABSOLUTE)
include(ClosureUtil)
set(usg_msg
"${CURRENT_FILENAME} ======================================================\n"
" The Closure CMake configuration file\n"
"\n"
" Usage from an external project\n"
"   In your CMakeLists.txt, add these line\n"
"\n"
"   find_package(Closure REQUIRED <COMPONENTS\n"
"   target_link_libraries(MY_TARGET_NAME \${Closure_LIBRARIES})\n"
"\n"
"   Or you can search for specific Closure module\n"
"\n"
"   find_package(Closure REQUIRED core highgu\n"
"\n"
"   If the module is found then Closure_<MODULE>_FOUND is set to TRUE\n"
"\n"
"   This file will define the following variable\n"
"     - Closure_FOUND           : TRUE if found, FALSE otherwise\n"
"     - Closure_LIBRARIES            : The list of libraries to links against\n"
"     - Closure_LIB_DIR         : The directory where lib files are\n"
"                                Calling LINK_DIRECTORIES  is NOT needed\n"
"     - Closure_INCLUDE_DIRS    : The Closure include directorie\n"
"     - Closure_BINARY_DIR      : The Closure binary directorie\n"
"   Advanced variable\n"
"     - Closure_SHARE\n"
"     - Closure_CONFIG_PATH\n"
"     - Closure_LIB_COMPONENTS\n"
"\n"
" ===========================================================================\n"
)
message(STATUS ${usg_msg})

look3d_print_status("Closure Dependencies Configuration")
look3d_print_status_colorized(Closure_COLOR_GREEN "Setting Closure libraries ...")

set(Closure_INCLUDE_DIRS "${Closure_ROOT}/include" "${Closure_ROOT}/include/look3d" "${Closure_ROOT}/include/look3d_external")
set(Closure_LIB_DIR "${Closure_ROOT}/lib")
set(Closure_BINARY_DIR  "${Closure_ROOT}/bin")

look3d_print_status("Closure_ROOT:${Closure_ROOT}")
look3d_print_status("Closure_INCLUDE_DIRS:${Closure_INCLUDE_DIRS}")
look3d_print_status("Closure_LIB_DIR:${Closure_LIB_DIR}")
look3d_print_status("Closure_BINARY_DIR:${Closure_BINARY_DIR}")

set(Closure_LIB_NAMES core feature2d geometry gsba math sensor track ui xsens)
foreach(LIB_NAME ${Closure_LIB_NAMES})
  # release mode built
  find_library(Closure_LIB_${LIB_NAME} look3d_${LIB_NAME} PATHS ${Closure_LIB_DIR})
  if(Closure_LIB_${LIB_NAME})
    list(APPEND Closure_LIBRARIES "optimized;${Closure_LIB_${LIB_NAME}};")
  endif()

  # debug mode built
  find_library(Closure_LIB_${LIB_NAME}_DEBUG look3d_${LIB_NAME}_d PATHS ${Closure_LIB_DIR})
  if(Closure_LIB_${LIB_NAME}_DEBUG)
    list(APPEND Closure_LIBRARIES "debug;${Closure_LIB_${LIB_NAME}_DEBUG};")
  endif()
endforeach(LIB_NAME)

if(Closure_INCLUDE_DIRS AND Closure_LIBRARIES)
  set(Closure_FOUND true)
endif()

look3d_print_status( "Closure_LIBRARIES:${Closure_LIBRARIES}")

if(Closure_FOUND)
  if(NOT Closure_FIND_QUIETLY)
      look3d_print_status( "Found Closure")
  endif(NOT Closure_FIND_QUIETLY)
else(Closure_FOUND)
  if(Closure_FIND_REQUIRED)
      look3d_print_error("Could not find the Closure Tracking libraries")
  endif(Closure_FIND_REQUIRED)
endif(Closure_FOUND)

# Dependencies =================================================================
look3d_print_status("Closure dependencies")

## Eigen
if(NOT EIGEN_INCLUDE_DIRS)
  set(EIGEN_INCLUDE_DIRS "${Closure_ROOT}/include/look3d_external")
  set(EIGEN_ROOT "${Closure_ROOT}/include/look3d_external")
endif()

## Boost
if(NOT Boost_INCLUDE_DIR)
  set(Boost_INCLUDE_DIR /usr/include)
endif()
find_package(Boost REQUIRED COMPONENTS thread system)
include_directories(${Boost_INCLUDE_DIR})
cull_library_paths(Boost_LIBRARIES)
set(Closure_EXTERNAL_LIBS ${Closure_EXTERNAL_LIBS} ${Boost_LIBRARIES})
link_directories(${Boost_LIBRARY_DIR})
set(Boost_BINARY_DIR "${Boost_LIBRARY_DIR}")
look3d_print_status("Boost include path: ${Boost_INCLUDE_DIR}")
look3d_print_status("Boost libs: ${Boost_LIBRARIES}")
look3d_print_status("Boost binary dir: ${Boost_BINARY_DIR}")

# OpenCV libraries
if(NOT OpenCV_DIR)
  set(OpenCV_DIR /usr/local/lib/cmake/opencv4)
endif()
find_package(OpenCV REQUIRED)
get_filename_component(OpenCV_BINARY_DIR "${OpenCV_LIB_DIR}/../bin" ABSOLUTE)
include_directories(${OpenCV_INCLUDE_DIRS})
cull_library_paths(OpenCV_LIBRARIES)
list(APPEND Closure_EXTRA_LIBRARIES ${OpenCV_LIBRARIES})
link_directories(${OpenCV_LIB_DIR})
look3d_print_status("OpenCV include paths: ${OpenCV_INCLUDE_DIRS}")
look3d_print_status("OpenCV libs: ${OpenCV_LIBRARIES}")
look3d_print_status("OpenCV binary dir: ${OpenCV_BINARY_DIR}")

## OpenGL
if(APPLE)
  list(APPEND Closure_EXTRA_INC_DIRS /opt/local/include)
  list(APPEND Closure_EXTRA_LIBRARIES ";-framework OpenGL;-framework GLUT;")
else()
  find_package(OpenGL REQUIRED)
  if(OpenGL_FOUND)
    list(APPEND Closure_EXTRA_INC_DIRS ${OpenGL_INC_DIR})
    list(APPEND Closure_EXTRA_LIBRARIES ${OpenGL_LIBRARIES})
  endif()
endif()

# # Qt4 libraries
# ## Qt4
# find_package(Qt4 REQUIRED)
# set(HAVE_QT4 ON)
# if(QT4_FOUND)
#   set(Closure_HAVE_QT ON)
#   set(QT_LIBRARIES ${QT_QTCORE_LIBRARY}  ${QT_QTXML_LIBRARY} ${QT_QTGUI_LIBRARY} ${QT_QTUITOOLS_LIBRARY} ${QT_QTOPENGL_LIBRARY})
#   list(APPEND Closure_EXTRA_INC_DIRS ${QT_INCLUDES})
#   list(APPEND Closure_EXTRA_LIBRARIES ${QT_LIBRARIES})
#   look3d_print_status(STATUS "Found Qt Version " ${QT_VERSION_MAJOR} "." ${QT_VERSION_MINOR} "." ${QT_VERSION_PATCH})
# endif(QT4_FOUND)

# # QGLViewer libraries
# if(QGLViewer_INCLUDE_DIR AND QGLViewer_LIBRARIES)
#   set(Closure_HAVE_QGLViewer ON)
#   set(QGLViewer_INCLUDE_DIR )
#   set(QGLViewer_LIBRARIES )
#   list(APPEND Closure_EXTRA_INC_DIRS ${QGLViewer_INCLUDE_DIR})
#   list(APPEND Closure_EXTRA_LIBRARIES ${QGLViewer_LIBRARIES})
# endif()

# # FlyCapture2
# if(FLYCAPTURE2_INCLUDE_DIR AND FLYCAPTURE2_LIBRARIES)
#   add_definitions(-DHAVE_FLYCAPTURE2)
#   set(FLYCAPTURE2_INCLUDE_DIR )
#   set(FLYCAPTURE2_LIBRARIES )
#   list(APPEND Closure_EXTRA_INC_DIRS ${FLYCAPTURE2_INCLUDE_DIR})
#   list(APPEND Closure_EXTRA_LIBRARIES ${FLYCAPTURE2_LIBRARIES})
# endif()

# # DC1394
# if(DC1394_2_INCLUDE_DIR AND DC1394_LIBRARIES)
#   add_definitions(-DHAVE_DC1394_2)
#   set(DC1394_2_INCLUDE_DIR )
#   set(DC1394_LIBRARIES )
#   list(APPEND Closure_EXTRA_INC_DIRS ${DC1394_2_INCLUDE_DIR})
#   list(APPEND Closure_EXTRA_LIBRARIES ${DC1394_LIBRARIES})
# endif()

# # UEye
# if(UEYE_INCLUDE_DIR AND UEYE_LIBRARIES)
#   add_definitions(-DHAVE_UEYE)
#   set(UEYE_INCLUDE_DIR )
#   set(UEYE_LIBRARIES )
#   list(APPEND Closure_EXTRA_INC_DIRS ${UEYE_INCLUDE_DIR})
#   list(APPEND Closure_EXTRA_LIBRARIES ${UEYE_LIBRARIES})
# endif(UEYE_INCLUDE_DIR AND UEYE_LIBRARIES)

# # fix for linking external libraries by name
# string(FIND "${Closure_EXTRA_LIBRARIES}" "tbb" Closure_EXTRA_HAVE_TBB)
# look3d_print_status("Closure_EXTRA_HAVE_TBB:${Closure_EXTRA_HAVE_TBB}")
# if(Closure_EXTRA_HAVE_TBB)
#   # set to path where there is tbb library
#   link_directories(/opt/local/lib)  # fix for -ltbb
# endif(Closure_EXTRA_HAVE_TBB)
