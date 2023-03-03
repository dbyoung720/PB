//
// This file is auto-generated. Please don't modify it!
//
package org.opencv.aruco;

import org.opencv.aruco.Dictionary;
import org.opencv.core.Mat;

// C++: class Dictionary
/**
 * Dictionary/Set of markers. It contains the inner codification
 *
 * bytesList contains the marker codewords where
 * - bytesList.rows is the dictionary size
 * - each marker is encoded using {@code nbytes = ceil(markerSize*markerSize/8.)}
 * - each row contains all 4 rotations of the marker, so its length is {@code 4*nbytes}
 *
 * {@code bytesList.ptr(i)[k*nbytes + j]} is then the j-th byte of i-th marker, in its k-th rotation.
 */
public class Dictionary {

    protected final long nativeObj;
    protected Dictionary(long addr) { nativeObj = addr; }

    public long getNativeObjAddr() { return nativeObj; }

    // internal usage only
    public static Dictionary __fromPtr__(long addr) { return new Dictionary(addr); }

    //
    // C++: static Ptr_Dictionary cv::aruco::Dictionary::create(int nMarkers, int markerSize, int randomSeed = 0)
    //

    /**
     * returns generateCustomDictionary(nMarkers, markerSize, randomSeed)
     * SEE: generateCustomDictionary
     * @param nMarkers automatically generated
     * @param markerSize automatically generated
     * @param randomSeed automatically generated
     * @return automatically generated
     */
    public static Dictionary create(int nMarkers, int markerSize, int randomSeed) {
        return Dictionary.__fromPtr__(create_0(nMarkers, markerSize, randomSeed));
    }

    /**
     * returns generateCustomDictionary(nMarkers, markerSize, randomSeed)
     * SEE: generateCustomDictionary
     * @param nMarkers automatically generated
     * @param markerSize automatically generated
     * @return automatically generated
     */
    public static Dictionary create(int nMarkers, int markerSize) {
        return Dictionary.__fromPtr__(create_1(nMarkers, markerSize));
    }


    //
    // C++: static Ptr_Dictionary cv::aruco::Dictionary::create(int nMarkers, int markerSize, Ptr_Dictionary baseDictionary, int randomSeed = 0)
    //

    /**
     * returns generateCustomDictionary(nMarkers, markerSize, baseDictionary, randomSeed)
     * SEE: generateCustomDictionary
     * @param nMarkers automatically generated
     * @param markerSize automatically generated
     * @param baseDictionary automatically generated
     * @param randomSeed automatically generated
     * @return automatically generated
     */
    public static Dictionary create_from(int nMarkers, int markerSize, Dictionary baseDictionary, int randomSeed) {
        return Dictionary.__fromPtr__(create_from_0(nMarkers, markerSize, baseDictionary.getNativeObjAddr(), randomSeed));
    }

    /**
     * returns generateCustomDictionary(nMarkers, markerSize, baseDictionary, randomSeed)
     * SEE: generateCustomDictionary
     * @param nMarkers automatically generated
     * @param markerSize automatically generated
     * @param baseDictionary automatically generated
     * @return automatically generated
     */
    public static Dictionary create_from(int nMarkers, int markerSize, Dictionary baseDictionary) {
        return Dictionary.__fromPtr__(create_from_1(nMarkers, markerSize, baseDictionary.getNativeObjAddr()));
    }


    //
    // C++:  bool cv::aruco::Dictionary::readDictionary(FileNode fn)
    //

    // Unknown type 'FileNode' (I), skipping the function


    //
    // C++:  void cv::aruco::Dictionary::writeDictionary(Ptr_FileStorage fs)
    //

    // Unknown type 'Ptr_FileStorage' (I), skipping the function


    //
    // C++: static Ptr_Dictionary cv::aruco::Dictionary::get(int dict)
    //

    /**
     * SEE: getPredefinedDictionary
     * @param dict automatically generated
     * @return automatically generated
     */
    public static Dictionary get(int dict) {
        return Dictionary.__fromPtr__(get_0(dict));
    }


    //
    // C++:  bool cv::aruco::Dictionary::identify(Mat onlyBits, int& idx, int& rotation, double maxCorrectionRate)
    //

    /**
     * Given a matrix of bits. Returns whether if marker is identified or not.
     * It returns by reference the correct id (if any) and the correct rotation
     * @param onlyBits automatically generated
     * @param idx automatically generated
     * @param rotation automatically generated
     * @param maxCorrectionRate automatically generated
     * @return automatically generated
     */
    public boolean identify(Mat onlyBits, int[] idx, int[] rotation, double maxCorrectionRate) {
        double[] idx_out = new double[1];
        double[] rotation_out = new double[1];
        boolean retVal = identify_0(nativeObj, onlyBits.nativeObj, idx_out, rotation_out, maxCorrectionRate);
        if(idx!=null) idx[0] = (int)idx_out[0];
        if(rotation!=null) rotation[0] = (int)rotation_out[0];
        return retVal;
    }


    //
    // C++:  int cv::aruco::Dictionary::getDistanceToId(Mat bits, int id, bool allRotations = true)
    //

    /**
     * Returns the distance of the input bits to the specific id. If allRotations is true,
     * the four posible bits rotation are considered
     * @param bits automatically generated
     * @param id automatically generated
     * @param allRotations automatically generated
     * @return automatically generated
     */
    public int getDistanceToId(Mat bits, int id, boolean allRotations) {
        return getDistanceToId_0(nativeObj, bits.nativeObj, id, allRotations);
    }

    /**
     * Returns the distance of the input bits to the specific id. If allRotations is true,
     * the four posible bits rotation are considered
     * @param bits automatically generated
     * @param id automatically generated
     * @return automatically generated
     */
    public int getDistanceToId(Mat bits, int id) {
        return getDistanceToId_1(nativeObj, bits.nativeObj, id);
    }


    //
    // C++:  void cv::aruco::Dictionary::drawMarker(int id, int sidePixels, Mat& _img, int borderBits = 1)
    //

    /**
     * Draw a canonical marker image
     * @param id automatically generated
     * @param sidePixels automatically generated
     * @param _img automatically generated
     * @param borderBits automatically generated
     */
    public void drawMarker(int id, int sidePixels, Mat _img, int borderBits) {
        drawMarker_0(nativeObj, id, sidePixels, _img.nativeObj, borderBits);
    }

    /**
     * Draw a canonical marker image
     * @param id automatically generated
     * @param sidePixels automatically generated
     * @param _img automatically generated
     */
    public void drawMarker(int id, int sidePixels, Mat _img) {
        drawMarker_1(nativeObj, id, sidePixels, _img.nativeObj);
    }


    //
    // C++: static Mat cv::aruco::Dictionary::getByteListFromBits(Mat bits)
    //

    /**
     * Transform matrix of bits to list of bytes in the 4 rotations
     * @param bits automatically generated
     * @return automatically generated
     */
    public static Mat getByteListFromBits(Mat bits) {
        return new Mat(getByteListFromBits_0(bits.nativeObj));
    }


    //
    // C++: static Mat cv::aruco::Dictionary::getBitsFromByteList(Mat byteList, int markerSize)
    //

    /**
     * Transform list of bytes to matrix of bits
     * @param byteList automatically generated
     * @param markerSize automatically generated
     * @return automatically generated
     */
    public static Mat getBitsFromByteList(Mat byteList, int markerSize) {
        return new Mat(getBitsFromByteList_0(byteList.nativeObj, markerSize));
    }


    //
    // C++: Mat Dictionary::bytesList
    //

    public Mat get_bytesList() {
        return new Mat(get_bytesList_0(nativeObj));
    }


    //
    // C++: void Dictionary::bytesList
    //

    public void set_bytesList(Mat bytesList) {
        set_bytesList_0(nativeObj, bytesList.nativeObj);
    }


    //
    // C++: int Dictionary::markerSize
    //

    public int get_markerSize() {
        return get_markerSize_0(nativeObj);
    }


    //
    // C++: void Dictionary::markerSize
    //

    public void set_markerSize(int markerSize) {
        set_markerSize_0(nativeObj, markerSize);
    }


    //
    // C++: int Dictionary::maxCorrectionBits
    //

    public int get_maxCorrectionBits() {
        return get_maxCorrectionBits_0(nativeObj);
    }


    //
    // C++: void Dictionary::maxCorrectionBits
    //

    public void set_maxCorrectionBits(int maxCorrectionBits) {
        set_maxCorrectionBits_0(nativeObj, maxCorrectionBits);
    }


    @Override
    protected void finalize() throws Throwable {
        delete(nativeObj);
    }



    // C++: static Ptr_Dictionary cv::aruco::Dictionary::create(int nMarkers, int markerSize, int randomSeed = 0)
    private static native long create_0(int nMarkers, int markerSize, int randomSeed);
    private static native long create_1(int nMarkers, int markerSize);

    // C++: static Ptr_Dictionary cv::aruco::Dictionary::create(int nMarkers, int markerSize, Ptr_Dictionary baseDictionary, int randomSeed = 0)
    private static native long create_from_0(int nMarkers, int markerSize, long baseDictionary_nativeObj, int randomSeed);
    private static native long create_from_1(int nMarkers, int markerSize, long baseDictionary_nativeObj);

    // C++: static Ptr_Dictionary cv::aruco::Dictionary::get(int dict)
    private static native long get_0(int dict);

    // C++:  bool cv::aruco::Dictionary::identify(Mat onlyBits, int& idx, int& rotation, double maxCorrectionRate)
    private static native boolean identify_0(long nativeObj, long onlyBits_nativeObj, double[] idx_out, double[] rotation_out, double maxCorrectionRate);

    // C++:  int cv::aruco::Dictionary::getDistanceToId(Mat bits, int id, bool allRotations = true)
    private static native int getDistanceToId_0(long nativeObj, long bits_nativeObj, int id, boolean allRotations);
    private static native int getDistanceToId_1(long nativeObj, long bits_nativeObj, int id);

    // C++:  void cv::aruco::Dictionary::drawMarker(int id, int sidePixels, Mat& _img, int borderBits = 1)
    private static native void drawMarker_0(long nativeObj, int id, int sidePixels, long _img_nativeObj, int borderBits);
    private static native void drawMarker_1(long nativeObj, int id, int sidePixels, long _img_nativeObj);

    // C++: static Mat cv::aruco::Dictionary::getByteListFromBits(Mat bits)
    private static native long getByteListFromBits_0(long bits_nativeObj);

    // C++: static Mat cv::aruco::Dictionary::getBitsFromByteList(Mat byteList, int markerSize)
    private static native long getBitsFromByteList_0(long byteList_nativeObj, int markerSize);

    // C++: Mat Dictionary::bytesList
    private static native long get_bytesList_0(long nativeObj);

    // C++: void Dictionary::bytesList
    private static native void set_bytesList_0(long nativeObj, long bytesList_nativeObj);

    // C++: int Dictionary::markerSize
    private static native int get_markerSize_0(long nativeObj);

    // C++: void Dictionary::markerSize
    private static native void set_markerSize_0(long nativeObj, int markerSize);

    // C++: int Dictionary::maxCorrectionBits
    private static native int get_maxCorrectionBits_0(long nativeObj);

    // C++: void Dictionary::maxCorrectionBits
    private static native void set_maxCorrectionBits_0(long nativeObj, int maxCorrectionBits);

    // native support for java finalize()
    private static native void delete(long nativeObj);

}
