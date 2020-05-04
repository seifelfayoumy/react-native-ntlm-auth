package com.neurony.ntlm;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.UnknownHostException;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

public class AuthenticationModule extends ReactContextBaseJavaModule
{
    public static final String NO_INTERNET_CONNECTION_ERROR_MESSAGE = "NO_INTERNET_CONNECTION_ERROR_MESSAGE";
    public static final String INVALID_USERNAME_OR_PASSWORD_ERROR_MESSAGE = "INVALID_USERNAME_OR_PASSWORD_ERROR_MESSAGE";

    public AuthenticationModule(ReactApplicationContext reactContext)
    {
        super(reactContext);
    }

    @Override
    public String getName()
    {
        return "NTLMAuthentication";
    }

    @ReactMethod
    public void login(String url, String username, String password,
                      final ReadableMap headers,
                      final Promise onResult)
    {
        final Authenticator authenticator=new Authenticator(username, password);

        OkHttpClient.Builder clientBuilder=new OkHttpClient.Builder()
                .followRedirects(true)
                .authenticator(authenticator)
                .followSslRedirects(true)
                .retryOnConnectionFailure(true)
                .cache(null)
                .connectTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS);

        if(headers!=null)
        {
            clientBuilder.addInterceptor(new Interceptor()
            {
                @Override
                public Response intercept(Chain chain) throws IOException
                {
                    Request original=chain.request();

                    Request.Builder requestBuilder=original.newBuilder();

                    ReadableMapKeySetIterator iterator=headers.keySetIterator();
                    while (iterator.hasNextKey())
                    {
                        String headerKey=iterator.nextKey();
                        String headerValue=headers.getString(headerKey);

                        requestBuilder.header(headerKey, headerValue);
                    }

                    Request request=requestBuilder
                            .method(original.method(), original.body())
                            .build();

                    return chain.proceed(request);
                }
            });
        }

        OkHttpClient client=clientBuilder.build();

        client.newCall(new Request.Builder().get().url(url).build())
            .enqueue(new Callback()
            {
                @Override
                public void onFailure(Call call, IOException ex)
                {
                    if (authenticator.invalidUsernameOrPassword)
                        onResult.reject(new RuntimeException(INVALID_USERNAME_OR_PASSWORD_ERROR_MESSAGE));
                    else if (ex instanceof UnknownHostException)
                        onResult.reject(new RuntimeException(NO_INTERNET_CONNECTION_ERROR_MESSAGE));
                    else onResult.reject(ex);
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException
                {
                    if (authenticator.invalidUsernameOrPassword)
                        onResult.reject(new RuntimeException(INVALID_USERNAME_OR_PASSWORD_ERROR_MESSAGE));
                    else
                    {
                        WritableMap headers=new WritableNativeMap();
                        Map<String, List<String>> okHttpHeaders=response.headers().toMultimap();
                        Set<String> headerKeys=okHttpHeaders.keySet();

                        for (String headerKey : headerKeys)
                        {
                            List<String> headerValues=okHttpHeaders.get(headerKey);
                            if (headerValues!=null&&!headerValues.isEmpty())
                                headers.putString(headerKey, headerValues.get(0));
                        }

                        WritableMap loginResult=new WritableNativeMap();
                        loginResult.putMap("headers", headers);

                        try
                        {
                            ResponseBody body=response.body();
                            JSONObject bodyJson=body!=null?new JSONObject(body.string()):new JSONObject();
                            loginResult.putMap("body", ReactJsonConvert.jsonToReact(bodyJson));
                            onResult.resolve(loginResult);
                        }
                        catch (JSONException ex)
                        {
                            onResult.reject(ex);
                        }
                    }
                }
            });
    }
}
