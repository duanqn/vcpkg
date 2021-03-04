vcpkg_fail_port_install(ON_ARCH "x86" "arm" ON_TARGET "UWP" "ANDROID" "FREEBSD" "OSX")

set(VERSION 1.7.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/onnxruntime
    REF v${VERSION}
    HEAD_REF master
    SHA512 bc50c3f87e81d717f25856487eb1b2e4562eb9149035f280fbd75579cffcb1454c77fb6b0db580f934b5c2cabf4d0ae98324f8ab302d272b7e1c423d589a60e8
)

set(SCRIPT_FILE ${SOURCE_PATH}/tools/ci_build/build.py)

if(VCPKG_TARGET_IS_WINDOWS)
    set(SHELL powershell -Command)
    set(COMMAND_PREFIX &)
endif()


vcpkg_find_acquire_program(PYTHON3)
find_program(GIT git REQUIRED)

execute_process(
    COMMAND ${GIT} init
    WORKING_DIRECTORY ${SOURCE_PATH}
)

execute_process(
    COMMAND ${GIT} remote add origin https://github.com/microsoft/onnxruntime.git
    WORKING_DIRECTORY ${SOURCE_PATH}
)

execute_process(
    COMMAND ${GIT} fetch origin refs/tags/v${VERSION}:refs/remotes/origin/v${VERSION}
    WORKING_DIRECTORY ${SOURCE_PATH}
)

execute_process(
    COMMAND ${GIT} reset --hard refs/tags/v${VERSION}
    WORKING_DIRECTORY ${SOURCE_PATH}
)

execute_process(
    COMMAND ${GIT} submodule sync --recursive
    WORKING_DIRECTORY ${SOURCE_PATH}
)

execute_process(
    COMMAND ${GIT} submodule update --init --recursive
    WORKING_DIRECTORY ${SOURCE_PATH}
)

vcpkg_execute_required_process(
    COMMAND ${SHELL} ${COMMAND_PREFIX} ${PYTHON3} ${SCRIPT_FILE} --parallel --config Release --build_shared_lib --build_dir ${SOURCE_PATH}/build --skip_submodule_sync --cmake_generator "Ninja"
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build
)
