//
// This file is auto-generated. Please don't modify it!
//
package org.opencv.aruco;

import java.util.ArrayList;
import java.util.List;
import org.opencv.aruco.Board;
import org.opencv.aruco.Dictionary;
import org.opencv.core.Mat;
import org.opencv.core.MatOfInt;
import org.opencv.core.MatOfPoint3f;
import org.opencv.core.Point3;
import org.opencv.utils.Converters;

// C++: class Board
/**
 * Board of markers
 *
 * A board is a set of markers in the 3D space with a common coordinate system.
 * The common form of a board of marker is a planar (2D) board, however any 3D layout can be used.
 * A Board object is composed by:
 * - The object points of the marker corners, i.e. their coordinates respect to the board system.
 * - The dictionary which indicates the type of markers of the board
 * - The identifier of all the markers in the board.
 */
public class Board {

    protected final long nativeObj;
    protected Board(long addr) { nativeObj = addr; }

    public long getNativeObjAddr() { return nativeObj; }

    // internal usage only
    public static Board __fromPtr__(long addr) { return new Board(addr); }

    //
    // C++:   cv::aruco::Board::Board()
    //

    public Board() {
        nativeObj = Board_0();
    }


    //
    // C++: static Ptr_Board cv::aruco::Board::create(vector_Mat objPoints, Ptr_Dictionary dictionary, Mat ids)
    //

    /**
     * Provide way to create Board by passing necessary data. Specially needed in Python.
     * @param objPoints array of object points of all the marker corners in the board
     * @param dictionary the dictionary of markers employed for this board
     * @param ids vector of the identifiers of the markers in the board
     * @return automatically generated
     */
    public static Board create(List<Mat> objPoints, Dictionary dictionary, Mat ids) {
        Mat objPoints_mat = Converters.vector_Mat_to_Mat(objPoints);
        return Board.__fromPtr__(create_0(objPoints_mat.nativeObj, dictionary.getNativeObjAddr(), ids.nativeObj));
    }


    //
    // C++:  void cv::aruco::Board::setIds(Mat ids)
    //

    /**
     * Set ids vector
     * @param ids vector of the identifiers of the markers in the board (should be the same size
     * as objPoints)
     *
     * Recommended way to set ids vector, which will fail if the size of ids does not match size
     * of objPoints.
     */
    public void setIds(Mat ids) {
        setIds_0(nativeObj, ids.nativeObj);
    }


    //
    // C++:  void cv::aruco::Board::changeId(int index, int newId)
    //

    /**
     * change id for ids[index]
     * @param index - element index in ids
     * @param newId - new value for ids[index], should be less than Dictionary size
     */
    public void changeId(int index, int newId) {
        changeId_0(nativeObj, index, newId);
    }


    //
    // C++:  vector_int cv::aruco::Board::getIds()
    //

    /**
     * return ids
     * @return automatically generated
     */
    public MatOfInt getIds() {
        return MatOfInt.fromNativeAddr(getIds_0(nativeObj));
    }


    //
    // C++:  void cv::aruco::Board::setDictionary(Ptr_Dictionary dictionary)
    //

    /**
     * set dictionary
     * @param dictionary automatically generated
     */
    public void setDictionary(Dictionary dictionary) {
        setDictionary_0(nativeObj, dictionary.getNativeObjAddr());
    }


    //
    // C++:  Ptr_Dictionary cv::aruco::Board::getDictionary()
    //

    /**
     * return dictionary
     * @return automatically generated
     */
    public Dictionary getDictionary() {
        return Dictionary.__fromPtr__(getDictionary_0(nativeObj));
    }


    //
    // C++:  void cv::aruco::Board::setObjPoints(vector_vector_Point3f objPoints)
    //

    /**
     * set objPoints
     * @param objPoints automatically generated
     */
    public void setObjPoints(List<MatOfPoint3f> objPoints) {
        List<Mat> objPoints_tmplm = new ArrayList<Mat>((objPoints != null) ? objPoints.size() : 0);
        Mat objPoints_mat = Converters.vector_vector_Point3f_to_Mat(objPoints, objPoints_tmplm);
        setObjPoints_0(nativeObj, objPoints_mat.nativeObj);
    }


    //
    // C++:  vector_vector_Point3f cv::aruco::Board::getObjPoints()
    //

    /**
     * get objPoints
     * @return automatically generated
     */
    public List<MatOfPoint3f> getObjPoints() {
        List<MatOfPoint3f> retVal = new ArrayList<MatOfPoint3f>();
        Mat retValMat = new Mat(getObjPoints_0(nativeObj));
        Converters.Mat_to_vector_vector_Point3f(retValMat, retVal);
        return retVal;
    }


    //
    // C++:  Point3f cv::aruco::Board::getRightBottomBorder()
    //

    /**
     * get rightBottomBorder
     * @return automatically generated
     */
    public Point3 getRightBottomBorder() {
        return new Point3(getRightBottomBorder_0(nativeObj));
    }


    @Override
    protected void finalize() throws Throwable {
        delete(nativeObj);
    }



    // C++:   cv::aruco::Board::Board()
    private static native long Board_0();

    // C++: static Ptr_Board cv::aruco::Board::create(vector_Mat objPoints, Ptr_Dictionary dictionary, Mat ids)
    private static native long create_0(long objPoints_mat_nativeObj, long dictionary_nativeObj, long ids_nativeObj);

    // C++:  void cv::aruco::Board::setIds(Mat ids)
    private static native void setIds_0(long nativeObj, long ids_nativeObj);

    // C++:  void cv::aruco::Board::changeId(int index, int newId)
    private static native void changeId_0(long nativeObj, int index, int newId);

    // C++:  vector_int cv::aruco::Board::getIds()
    private static native long getIds_0(long nativeObj);

    // C++:  void cv::aruco::Board::setDictionary(Ptr_Dictionary dictionary)
    private static native void setDictionary_0(long nativeObj, long dictionary_nativeObj);

    // C++:  Ptr_Dictionary cv::aruco::Board::getDictionary()
    private static native long getDictionary_0(long nativeObj);

    // C++:  void cv::aruco::Board::setObjPoints(vector_vector_Point3f objPoints)
    private static native void setObjPoints_0(long nativeObj, long objPoints_mat_nativeObj);

    // C++:  vector_vector_Point3f cv::aruco::Board::getObjPoints()
    private static native long getObjPoints_0(long nativeObj);

    // C++:  Point3f cv::aruco::Board::getRightBottomBorder()
    private static native double[] getRightBottomBorder_0(long nativeObj);

    // native support for java finalize()
    private static native void delete(long nativeObj);

}
