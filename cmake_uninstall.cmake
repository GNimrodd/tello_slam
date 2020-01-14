MESSAGE(STATUS "Uninstalling")
IF (NOT EXISTS "/home/nimrodd/code/lsd_slam_noros/install_manifest.txt")
  MESSAGE(FATAL_ERROR "Cannot find install manifest: \"/home/nimrodd/code/lsd_slam_noros/install_manifest.txt\"")
ENDIF(NOT EXISTS "/home/nimrodd/code/lsd_slam_noros/install_manifest.txt")

FILE(READ "/home/nimrodd/code/lsd_slam_noros/install_manifest.txt" files)
STRING(REPLACE "\n" ";" files "${files}")
FOREACH (file ${files})
    MESSAGE(STATUS "Uninstalling \"$ENV{DESTDIR}${file}\"")
    IF (EXISTS "$ENV{DESTDIR}${file}")
        EXECUTE_PROCESS(
            COMMAND /snap/clion/99/bin/cmake/linux/bin/cmake -E remove "$ENV{DESTDIR}${file}"
            OUTPUT_VARIABLE rm_out
            RESULT_VARIABLE rm_retval
        )
        IF(NOT ${rm_retval} EQUAL 0)
            MESSAGE(FATAL_ERROR 
          "Problem when removing \"$ENV{DESTDIR}${file}\"")
        ENDIF (NOT ${rm_retval} EQUAL 0)
    ELSE (EXISTS "$ENV{DESTDIR}${file}")
        MESSAGE(STATUS "File \"$ENV{DESTDIR}${file}\" does not exist.")
    ENDIF (EXISTS "$ENV{DESTDIR}${file}")
ENDFOREACH(file)
