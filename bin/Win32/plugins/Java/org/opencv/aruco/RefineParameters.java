//
// This file is auto-generated. Please don't modify it!
//
package org.opencv.aruco;

import org.opencv.aruco.RefineParameters;

// C++: class RefineParameters
/**
 * struct RefineParameters is used by ArucoDetector
 */
public class RefineParameters {

    protected final long nativeObj;
    protected RefineParameters(long addr) { nativeObj = addr; }

    public long getNativeObjAddr() { return nativeObj; }

    // internal usage only
    public static RefineParameters __fromPtr__(long addr) { return new RefineParameters(addr); }

    //
    // C++: static Ptr_RefineParameters cv::aruco::RefineParameters::create(float _minRepDistance = 10.f, float _errorCorrectionRate = 3.f, bool _checkAllOrders = true)
    //

    public static RefineParameters create(float _minRepDistance, float _errorCorrectionRate, boolean _checkAllOrders) {
        return RefineParameters.__fromPtr__(create_0(_minRepDistance, _errorCorrectionRate, _checkAllOrders));
    }

    public static RefineParameters create(float _minRepDistance, float _errorCorrectionRate) {
        return RefineParameters.__fromPtr__(create_1(_minRepDistance, _errorCorrectionRate));
    }

    public static RefineParameters create(float _minRepDistance) {
        return RefineParameters.__fromPtr__(create_2(_minRepDistance));
    }

    public static RefineParameters create() {
        return RefineParameters.__fromPtr__(create_3());
    }


    //
    // C++:  bool cv::aruco::RefineParameters::readRefineParameters(FileNode fn)
    //

    // Unknown type 'FileNode' (I), skipping the function


    //
    // C++:  bool cv::aruco::RefineParameters::writeRefineParameters(Ptr_FileStorage fs)
    //

    // Unknown type 'Ptr_FileStorage' (I), skipping the function


    //
    // C++: float RefineParameters::minRepDistance
    //

    public float get_minRepDistance() {
        return get_minRepDistance_0(nativeObj);
    }


    //
    // C++: void RefineParameters::minRepDistance
    //

    public void set_minRepDistance(float minRepDistance) {
        set_minRepDistance_0(nativeObj, minRepDistance);
    }


    //
    // C++: float RefineParameters::errorCorrectionRate
    //

    public float get_errorCorrectionRate() {
        return get_errorCorrectionRate_0(nativeObj);
    }


    //
    // C++: void RefineParameters::errorCorrectionRate
    //

    public void set_errorCorrectionRate(float errorCorrectionRate) {
        set_errorCorrectionRate_0(nativeObj, errorCorrectionRate);
    }


    //
    // C++: bool RefineParameters::checkAllOrders
    //

    public boolean get_checkAllOrders() {
        return get_checkAllOrders_0(nativeObj);
    }


    //
    // C++: void RefineParameters::checkAllOrders
    //

    public void set_checkAllOrders(boolean checkAllOrders) {
        set_checkAllOrders_0(nativeObj, checkAllOrders);
    }


    @Override
    protected void finalize() throws Throwable {
        delete(nativeObj);
    }



    // C++: static Ptr_RefineParameters cv::aruco::RefineParameters::create(float _minRepDistance = 10.f, float _errorCorrectionRate = 3.f, bool _checkAllOrders = true)
    private static native long create_0(float _minRepDistance, float _errorCorrectionRate, boolean _checkAllOrders);
    private static native long create_1(float _minRepDistance, float _errorCorrectionRate);
    private static native long create_2(float _minRepDistance);
    private static native long create_3();

    // C++: float RefineParameters::minRepDistance
    private static native float get_minRepDistance_0(long nativeObj);

    // C++: void RefineParameters::minRepDistance
    private static native void set_minRepDistance_0(long nativeObj, float minRepDistance);

    // C++: float RefineParameters::errorCorrectionRate
    private static native float get_errorCorrectionRate_0(long nativeObj);

    // C++: void RefineParameters::errorCorrectionRate
    private static native void set_errorCorrectionRate_0(long nativeObj, float errorCorrectionRate);

    // C++: bool RefineParameters::checkAllOrders
    private static native boolean get_checkAllOrders_0(long nativeObj);

    // C++: void RefineParameters::checkAllOrders
    private static native void set_checkAllOrders_0(long nativeObj, boolean checkAllOrders);

    // native support for java finalize()
    private static native void delete(long nativeObj);

}
