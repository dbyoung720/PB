//
// This file is auto-generated. Please don't modify it!
//
package org.opencv.aruco;

import java.util.ArrayList;
import java.util.List;
import org.opencv.aruco.ArucoDetector;
import org.opencv.aruco.Board;
import org.opencv.aruco.DetectorParameters;
import org.opencv.aruco.Dictionary;
import org.opencv.aruco.RefineParameters;
import org.opencv.core.Algorithm;
import org.opencv.core.Mat;
import org.opencv.utils.Converters;

// C++: class ArucoDetector
/**
 * The main functionality of ArucoDetector class is detection of markers in an image with detectMarkers() method.
 * After detecting some markers in the image, you can try to find undetected markers from this dictionary with
 * refineDetectedMarkers() method.
 * SEE: DetectorParameters, RefineParameters
 */
public class ArucoDetector extends Algorithm {

    protected ArucoDetector(long addr) { super(addr); }

    // internal usage only
    public static ArucoDetector __fromPtr__(long addr) { return new ArucoDetector(addr); }

    //
    // C++:   cv::aruco::ArucoDetector::ArucoDetector(Ptr_Dictionary _dictionary = getPredefinedDictionary(DICT_4X4_50), Ptr_DetectorParameters _params = DetectorParameters::create(), Ptr_RefineParameters _refineParams = RefineParameters::create())
    //

    /**
     * Basic ArucoDetector constructor
     * @param _dictionary indicates the type of markers that will be searched
     * @param _params marker detection parameters
     * @param _refineParams marker refine detection parameters
     */
    public ArucoDetector(Dictionary _dictionary, DetectorParameters _params, RefineParameters _refineParams) {
        super(ArucoDetector_0(_dictionary.getNativeObjAddr(), _params.getNativeObjAddr(), _refineParams.getNativeObjAddr()));
    }

    /**
     * Basic ArucoDetector constructor
     * @param _dictionary indicates the type of markers that will be searched
     * @param _params marker detection parameters
     */
    public ArucoDetector(Dictionary _dictionary, DetectorParameters _params) {
        super(ArucoDetector_1(_dictionary.getNativeObjAddr(), _params.getNativeObjAddr()));
    }

    /**
     * Basic ArucoDetector constructor
     * @param _dictionary indicates the type of markers that will be searched
     */
    public ArucoDetector(Dictionary _dictionary) {
        super(ArucoDetector_2(_dictionary.getNativeObjAddr()));
    }

    /**
     * Basic ArucoDetector constructor
     */
    public ArucoDetector() {
        super(ArucoDetector_3());
    }


    //
    // C++: static Ptr_ArucoDetector cv::aruco::ArucoDetector::create(Ptr_Dictionary _dictionary, Ptr_DetectorParameters _params)
    //

    public static ArucoDetector create(Dictionary _dictionary, DetectorParameters _params) {
        return ArucoDetector.__fromPtr__(create_0(_dictionary.getNativeObjAddr(), _params.getNativeObjAddr()));
    }


    //
    // C++:  void cv::aruco::ArucoDetector::detectMarkers(Mat image, vector_Mat& corners, Mat& ids, vector_Mat& rejectedImgPoints = vector_Mat())
    //

    /**
     * Basic marker detection
     *
     * @param image input image
     * @param corners vector of detected marker corners. For each marker, its four corners
     * are provided, (e.g std::vector&lt;std::vector&lt;cv::Point2f&gt; &gt; ). For N detected markers,
     * the dimensions of this array is Nx4. The order of the corners is clockwise.
     * @param ids vector of identifiers of the detected markers. The identifier is of type int
     * (e.g. std::vector&lt;int&gt;). For N detected markers, the size of ids is also N.
     * The identifiers have the same order than the markers in the imgPoints array.
     * @param rejectedImgPoints contains the imgPoints of those squares whose inner code has not a
     * correct codification. Useful for debugging purposes.
     *
     * Performs marker detection in the input image. Only markers included in the specific dictionary
     * are searched. For each detected marker, it returns the 2D position of its corner in the image
     * and its corresponding identifier.
     * Note that this function does not perform pose estimation.
     * <b>Note:</b> The function does not correct lens distortion or takes it into account. It's recommended to undistort
     * input image with corresponging camera model, if camera parameters are known
     * SEE: undistort, estimatePoseSingleMarkers,  estimatePoseBoard
     */
    public void detectMarkers(Mat image, List<Mat> corners, Mat ids, List<Mat> rejectedImgPoints) {
        Mat corners_mat = new Mat();
        Mat rejectedImgPoints_mat = new Mat();
        detectMarkers_0(nativeObj, image.nativeObj, corners_mat.nativeObj, ids.nativeObj, rejectedImgPoints_mat.nativeObj);
        Converters.Mat_to_vector_Mat(corners_mat, corners);
        corners_mat.release();
        Converters.Mat_to_vector_Mat(rejectedImgPoints_mat, rejectedImgPoints);
        rejectedImgPoints_mat.release();
    }

    /**
     * Basic marker detection
     *
     * @param image input image
     * @param corners vector of detected marker corners. For each marker, its four corners
     * are provided, (e.g std::vector&lt;std::vector&lt;cv::Point2f&gt; &gt; ). For N detected markers,
     * the dimensions of this array is Nx4. The order of the corners is clockwise.
     * @param ids vector of identifiers of the detected markers. The identifier is of type int
     * (e.g. std::vector&lt;int&gt;). For N detected markers, the size of ids is also N.
     * The identifiers have the same order than the markers in the imgPoints array.
     * correct codification. Useful for debugging purposes.
     *
     * Performs marker detection in the input image. Only markers included in the specific dictionary
     * are searched. For each detected marker, it returns the 2D position of its corner in the image
     * and its corresponding identifier.
     * Note that this function does not perform pose estimation.
     * <b>Note:</b> The function does not correct lens distortion or takes it into account. It's recommended to undistort
     * input image with corresponging camera model, if camera parameters are known
     * SEE: undistort, estimatePoseSingleMarkers,  estimatePoseBoard
     */
    public void detectMarkers(Mat image, List<Mat> corners, Mat ids) {
        Mat corners_mat = new Mat();
        detectMarkers_1(nativeObj, image.nativeObj, corners_mat.nativeObj, ids.nativeObj);
        Converters.Mat_to_vector_Mat(corners_mat, corners);
        corners_mat.release();
    }


    //
    // C++:  void cv::aruco::ArucoDetector::refineDetectedMarkers(Mat image, Ptr_Board board, vector_Mat& detectedCorners, Mat& detectedIds, vector_Mat& rejectedCorners, Mat cameraMatrix = Mat(), Mat distCoeffs = Mat(), Mat& recoveredIdxs = Mat())
    //

    /**
     * Refind not detected markers based on the already detected and the board layout
     *
     * @param image input image
     * @param board layout of markers in the board.
     * @param detectedCorners vector of already detected marker corners.
     * @param detectedIds vector of already detected marker identifiers.
     * @param rejectedCorners vector of rejected candidates during the marker detection process.
     * @param cameraMatrix optional input 3x3 floating-point camera matrix
     * \(A = \vecthreethree{f_x}{0}{c_x}{0}{f_y}{c_y}{0}{0}{1}\)
     * @param distCoeffs optional vector of distortion coefficients
     * \((k_1, k_2, p_1, p_2[, k_3[, k_4, k_5, k_6],[s_1, s_2, s_3, s_4]])\) of 4, 5, 8 or 12 elements
     * @param recoveredIdxs Optional array to returns the indexes of the recovered candidates in the
     * original rejectedCorners array.
     *
     * This function tries to find markers that were not detected in the basic detecMarkers function.
     * First, based on the current detected marker and the board layout, the function interpolates
     * the position of the missing markers. Then it tries to find correspondence between the reprojected
     * markers and the rejected candidates based on the minRepDistance and errorCorrectionRate
     * parameters.
     * If camera parameters and distortion coefficients are provided, missing markers are reprojected
     * using projectPoint function. If not, missing marker projections are interpolated using global
     * homography, and all the marker corners in the board must have the same Z coordinate.
     */
    public void refineDetectedMarkers(Mat image, Board board, List<Mat> detectedCorners, Mat detectedIds, List<Mat> rejectedCorners, Mat cameraMatrix, Mat distCoeffs, Mat recoveredIdxs) {
        Mat detectedCorners_mat = Converters.vector_Mat_to_Mat(detectedCorners);
        Mat rejectedCorners_mat = Converters.vector_Mat_to_Mat(rejectedCorners);
        refineDetectedMarkers_0(nativeObj, image.nativeObj, board.getNativeObjAddr(), detectedCorners_mat.nativeObj, detectedIds.nativeObj, rejectedCorners_mat.nativeObj, cameraMatrix.nativeObj, distCoeffs.nativeObj, recoveredIdxs.nativeObj);
        Converters.Mat_to_vector_Mat(detectedCorners_mat, detectedCorners);
        detectedCorners_mat.release();
        Converters.Mat_to_vector_Mat(rejectedCorners_mat, rejectedCorners);
        rejectedCorners_mat.release();
    }

    /**
     * Refind not detected markers based on the already detected and the board layout
     *
     * @param image input image
     * @param board layout of markers in the board.
     * @param detectedCorners vector of already detected marker corners.
     * @param detectedIds vector of already detected marker identifiers.
     * @param rejectedCorners vector of rejected candidates during the marker detection process.
     * @param cameraMatrix optional input 3x3 floating-point camera matrix
     * \(A = \vecthreethree{f_x}{0}{c_x}{0}{f_y}{c_y}{0}{0}{1}\)
     * @param distCoeffs optional vector of distortion coefficients
     * \((k_1, k_2, p_1, p_2[, k_3[, k_4, k_5, k_6],[s_1, s_2, s_3, s_4]])\) of 4, 5, 8 or 12 elements
     * original rejectedCorners array.
     *
     * This function tries to find markers that were not detected in the basic detecMarkers function.
     * First, based on the current detected marker and the board layout, the function interpolates
     * the position of the missing markers. Then it tries to find correspondence between the reprojected
     * markers and the rejected candidates based on the minRepDistance and errorCorrectionRate
     * parameters.
     * If camera parameters and distortion coefficients are provided, missing markers are reprojected
     * using projectPoint function. If not, missing marker projections are interpolated using global
     * homography, and all the marker corners in the board must have the same Z coordinate.
     */
    public void refineDetectedMarkers(Mat image, Board board, List<Mat> detectedCorners, Mat detectedIds, List<Mat> rejectedCorners, Mat cameraMatrix, Mat distCoeffs) {
        Mat detectedCorners_mat = Converters.vector_Mat_to_Mat(detectedCorners);
        Mat rejectedCorners_mat = Converters.vector_Mat_to_Mat(rejectedCorners);
        refineDetectedMarkers_1(nativeObj, image.nativeObj, board.getNativeObjAddr(), detectedCorners_mat.nativeObj, detectedIds.nativeObj, rejectedCorners_mat.nativeObj, cameraMatrix.nativeObj, distCoeffs.nativeObj);
        Converters.Mat_to_vector_Mat(detectedCorners_mat, detectedCorners);
        detectedCorners_mat.release();
        Converters.Mat_to_vector_Mat(rejectedCorners_mat, rejectedCorners);
        rejectedCorners_mat.release();
    }

    /**
     * Refind not detected markers based on the already detected and the board layout
     *
     * @param image input image
     * @param board layout of markers in the board.
     * @param detectedCorners vector of already detected marker corners.
     * @param detectedIds vector of already detected marker identifiers.
     * @param rejectedCorners vector of rejected candidates during the marker detection process.
     * @param cameraMatrix optional input 3x3 floating-point camera matrix
     * \(A = \vecthreethree{f_x}{0}{c_x}{0}{f_y}{c_y}{0}{0}{1}\)
     * \((k_1, k_2, p_1, p_2[, k_3[, k_4, k_5, k_6],[s_1, s_2, s_3, s_4]])\) of 4, 5, 8 or 12 elements
     * original rejectedCorners array.
     *
     * This function tries to find markers that were not detected in the basic detecMarkers function.
     * First, based on the current detected marker and the board layout, the function interpolates
     * the position of the missing markers. Then it tries to find correspondence between the reprojected
     * markers and the rejected candidates based on the minRepDistance and errorCorrectionRate
     * parameters.
     * If camera parameters and distortion coefficients are provided, missing markers are reprojected
     * using projectPoint function. If not, missing marker projections are interpolated using global
     * homography, and all the marker corners in the board must have the same Z coordinate.
     */
    public void refineDetectedMarkers(Mat image, Board board, List<Mat> detectedCorners, Mat detectedIds, List<Mat> rejectedCorners, Mat cameraMatrix) {
        Mat detectedCorners_mat = Converters.vector_Mat_to_Mat(detectedCorners);
        Mat rejectedCorners_mat = Converters.vector_Mat_to_Mat(rejectedCorners);
        refineDetectedMarkers_2(nativeObj, image.nativeObj, board.getNativeObjAddr(), detectedCorners_mat.nativeObj, detectedIds.nativeObj, rejectedCorners_mat.nativeObj, cameraMatrix.nativeObj);
        Converters.Mat_to_vector_Mat(detectedCorners_mat, detectedCorners);
        detectedCorners_mat.release();
        Converters.Mat_to_vector_Mat(rejectedCorners_mat, rejectedCorners);
        rejectedCorners_mat.release();
    }

    /**
     * Refind not detected markers based on the already detected and the board layout
     *
     * @param image input image
     * @param board layout of markers in the board.
     * @param detectedCorners vector of already detected marker corners.
     * @param detectedIds vector of already detected marker identifiers.
     * @param rejectedCorners vector of rejected candidates during the marker detection process.
     * \(A = \vecthreethree{f_x}{0}{c_x}{0}{f_y}{c_y}{0}{0}{1}\)
     * \((k_1, k_2, p_1, p_2[, k_3[, k_4, k_5, k_6],[s_1, s_2, s_3, s_4]])\) of 4, 5, 8 or 12 elements
     * original rejectedCorners array.
     *
     * This function tries to find markers that were not detected in the basic detecMarkers function.
     * First, based on the current detected marker and the board layout, the function interpolates
     * the position of the missing markers. Then it tries to find correspondence between the reprojected
     * markers and the rejected candidates based on the minRepDistance and errorCorrectionRate
     * parameters.
     * If camera parameters and distortion coefficients are provided, missing markers are reprojected
     * using projectPoint function. If not, missing marker projections are interpolated using global
     * homography, and all the marker corners in the board must have the same Z coordinate.
     */
    public void refineDetectedMarkers(Mat image, Board board, List<Mat> detectedCorners, Mat detectedIds, List<Mat> rejectedCorners) {
        Mat detectedCorners_mat = Converters.vector_Mat_to_Mat(detectedCorners);
        Mat rejectedCorners_mat = Converters.vector_Mat_to_Mat(rejectedCorners);
        refineDetectedMarkers_3(nativeObj, image.nativeObj, board.getNativeObjAddr(), detectedCorners_mat.nativeObj, detectedIds.nativeObj, rejectedCorners_mat.nativeObj);
        Converters.Mat_to_vector_Mat(detectedCorners_mat, detectedCorners);
        detectedCorners_mat.release();
        Converters.Mat_to_vector_Mat(rejectedCorners_mat, rejectedCorners);
        rejectedCorners_mat.release();
    }


    //
    // C++:  void cv::aruco::ArucoDetector::write(String fileName)
    //

    /**
     * simplified API for language bindings
     *
     * @param fileName automatically generated
     */
    public void write(String fileName) {
        write_0(nativeObj, fileName);
    }


    //
    // C++:  void cv::aruco::ArucoDetector::read(FileNode fn)
    //

    // Unknown type 'FileNode' (I), skipping the function


    //
    // C++: Ptr_Dictionary ArucoDetector::dictionary
    //

    public Dictionary get_dictionary() {
        return Dictionary.__fromPtr__(get_dictionary_0(nativeObj));
    }


    //
    // C++: void ArucoDetector::dictionary
    //

    public void set_dictionary(Dictionary dictionary) {
        set_dictionary_0(nativeObj, dictionary.getNativeObjAddr());
    }


    //
    // C++: Ptr_DetectorParameters ArucoDetector::params
    //

    public DetectorParameters get_params() {
        return DetectorParameters.__fromPtr__(get_params_0(nativeObj));
    }


    //
    // C++: void ArucoDetector::params
    //

    public void set_params(DetectorParameters params) {
        set_params_0(nativeObj, params.getNativeObjAddr());
    }


    //
    // C++: Ptr_RefineParameters ArucoDetector::refineParams
    //

    public RefineParameters get_refineParams() {
        return RefineParameters.__fromPtr__(get_refineParams_0(nativeObj));
    }


    //
    // C++: void ArucoDetector::refineParams
    //

    public void set_refineParams(RefineParameters refineParams) {
        set_refineParams_0(nativeObj, refineParams.getNativeObjAddr());
    }


    @Override
    protected void finalize() throws Throwable {
        delete(nativeObj);
    }



    // C++:   cv::aruco::ArucoDetector::ArucoDetector(Ptr_Dictionary _dictionary = getPredefinedDictionary(DICT_4X4_50), Ptr_DetectorParameters _params = DetectorParameters::create(), Ptr_RefineParameters _refineParams = RefineParameters::create())
    private static native long ArucoDetector_0(long _dictionary_nativeObj, long _params_nativeObj, long _refineParams_nativeObj);
    private static native long ArucoDetector_1(long _dictionary_nativeObj, long _params_nativeObj);
    private static native long ArucoDetector_2(long _dictionary_nativeObj);
    private static native long ArucoDetector_3();

    // C++: static Ptr_ArucoDetector cv::aruco::ArucoDetector::create(Ptr_Dictionary _dictionary, Ptr_DetectorParameters _params)
    private static native long create_0(long _dictionary_nativeObj, long _params_nativeObj);

    // C++:  void cv::aruco::ArucoDetector::detectMarkers(Mat image, vector_Mat& corners, Mat& ids, vector_Mat& rejectedImgPoints = vector_Mat())
    private static native void detectMarkers_0(long nativeObj, long image_nativeObj, long corners_mat_nativeObj, long ids_nativeObj, long rejectedImgPoints_mat_nativeObj);
    private static native void detectMarkers_1(long nativeObj, long image_nativeObj, long corners_mat_nativeObj, long ids_nativeObj);

    // C++:  void cv::aruco::ArucoDetector::refineDetectedMarkers(Mat image, Ptr_Board board, vector_Mat& detectedCorners, Mat& detectedIds, vector_Mat& rejectedCorners, Mat cameraMatrix = Mat(), Mat distCoeffs = Mat(), Mat& recoveredIdxs = Mat())
    private static native void refineDetectedMarkers_0(long nativeObj, long image_nativeObj, long board_nativeObj, long detectedCorners_mat_nativeObj, long detectedIds_nativeObj, long rejectedCorners_mat_nativeObj, long cameraMatrix_nativeObj, long distCoeffs_nativeObj, long recoveredIdxs_nativeObj);
    private static native void refineDetectedMarkers_1(long nativeObj, long image_nativeObj, long board_nativeObj, long detectedCorners_mat_nativeObj, long detectedIds_nativeObj, long rejectedCorners_mat_nativeObj, long cameraMatrix_nativeObj, long distCoeffs_nativeObj);
    private static native void refineDetectedMarkers_2(long nativeObj, long image_nativeObj, long board_nativeObj, long detectedCorners_mat_nativeObj, long detectedIds_nativeObj, long rejectedCorners_mat_nativeObj, long cameraMatrix_nativeObj);
    private static native void refineDetectedMarkers_3(long nativeObj, long image_nativeObj, long board_nativeObj, long detectedCorners_mat_nativeObj, long detectedIds_nativeObj, long rejectedCorners_mat_nativeObj);

    // C++:  void cv::aruco::ArucoDetector::write(String fileName)
    private static native void write_0(long nativeObj, String fileName);

    // C++: Ptr_Dictionary ArucoDetector::dictionary
    private static native long get_dictionary_0(long nativeObj);

    // C++: void ArucoDetector::dictionary
    private static native void set_dictionary_0(long nativeObj, long dictionary_nativeObj);

    // C++: Ptr_DetectorParameters ArucoDetector::params
    private static native long get_params_0(long nativeObj);

    // C++: void ArucoDetector::params
    private static native void set_params_0(long nativeObj, long params_nativeObj);

    // C++: Ptr_RefineParameters ArucoDetector::refineParams
    private static native long get_refineParams_0(long nativeObj);

    // C++: void ArucoDetector::refineParams
    private static native void set_refineParams_0(long nativeObj, long refineParams_nativeObj);

    // native support for java finalize()
    private static native void delete(long nativeObj);

}
