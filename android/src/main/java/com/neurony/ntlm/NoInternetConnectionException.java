package com.neurony.ntlm;

import java.io.IOException;
import java.net.SocketException;
import java.net.SocketTimeoutException;

/**
 * Created by andreiradoi on 04/07/2019.
 */

public class NoInternetConnectionException extends RuntimeException
{
    public static boolean equals(Throwable that)
    {
        if (that instanceof SocketTimeoutException) return true;
        if (that instanceof SocketException) return true;
        if (that instanceof IOException && that.getMessage()!=null&&
            that.getMessage().contains("unexpected end of stream on Connection")) return true;

        return false;
    }
}
