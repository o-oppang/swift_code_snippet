PROJECT_NAME="project_name"
FRAMEWORK_NAME="project_name"
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal
 
# Make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"
 
# Next, work out if we're in SIM or DEVICE
xcodebuild -target "${PROJECT_NAME}" -configuration ${CONFIGURATION} -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build

lipo -remove arm64 "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" -o "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

xcodebuild -target "${PROJECT_NAME}" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
 
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}"
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule/." "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule"
 rm -rf "${BUILD_DIR}/${CONFIGURATION}-universal/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"
lipo -output "${BUILD_DIR}/${CONFIGURATION}-universal/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" -create  "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"
 
open "${UNIVERSAL_OUTPUTFOLDER}"
