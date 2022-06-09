package com.hx.flutter_pay.net;

import androidx.annotation.Nullable;

import com.google.gson.FieldNamingPolicy;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Headers;
import okhttp3.HttpUrl;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;

/**
 * Created by imndx on 2017/12/15.
 */

public class OKHttpHelper {
    private static OkHttpClient okHttpClient = new OkHttpClient.Builder()
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build();

    private static Gson gson = new GsonBuilder()
            .setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES)
            .create();
    private static final MediaType JSON = MediaType.parse("application/json; charset=utf-8");

    public static <T> void get(final String url, Map<String, String> params, final Callback<T> callback) {
        HttpUrl httpUrl = HttpUrl.parse(url);
        if (params != null) {
            HttpUrl.Builder builder = httpUrl.newBuilder();
            for (Map.Entry<String, String> entry : params.entrySet()) {
                builder.addQueryParameter(entry.getKey(), entry.getValue());
            }
            httpUrl = builder.build();
        }

        final Request request = new Request.Builder()
                .url(httpUrl)
                .get()
                .build();

        okHttpClient.newCall(request).enqueue(new okhttp3.Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                if (callback != null) {
                    callback.onFailure(-1, e.getMessage());
                }
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                handleResponse(url, call, response, callback);
            }
        });

    }

    public static <T> void get(final String url, @Nullable Map<String, String> headerMap, Map<String, String> params, final Callback<T> callback) {
        HttpUrl httpUrl = HttpUrl.parse(url);
        Headers.Builder headerBuilder = new Headers.Builder();
        if (headerMap != null) {
            for (Map.Entry<String, String> entry : headerMap.entrySet()) {
                headerBuilder.add(entry.getKey(), entry.getValue());
            }
        }
        if (params != null) {
            HttpUrl.Builder builder = httpUrl.newBuilder();
            for (Map.Entry<String, String> entry : params.entrySet()) {
                builder.addQueryParameter(entry.getKey(), entry.getValue());
            }
            httpUrl = builder.build();
        }

        final Request request = new Request.Builder()
                .headers(headerBuilder.build())
                .url(httpUrl)
                .get()
                .build();

        okHttpClient.newCall(request).enqueue(new okhttp3.Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                if (callback != null) {
                    callback.onFailure(-1, e.getMessage());
                }
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                handleResponse(url, call, response, callback);
            }
        });
    }


    public static <T> T synPost(final String url, Headers headers, Map<String, Object> param, Class<T> type) throws IOException {
        RequestBody body = RequestBody.create(JSON, gson.toJson(param));
        if (headers == null) {
            headers = new Headers.Builder()
                    .add("Content-Type", "application/json")
                    .build();
        }
        final Request request = new Request.Builder()
                .headers(headers)
                .url(url)
                .post(body)
                .build();
        Response response = okHttpClient.newCall(request).execute();
        if (response.isSuccessful()) {
            RespResult<T> respResult = fromJsonObject(response.body().string(), type);
            return respResult.getData();
        }
        return null;
    }

    public static <T> void post(final String url, @Nullable Headers headers, Map<String, Object> param, final Callback<T> callback) {
        RequestBody body = RequestBody.create(JSON, gson.toJson(param));
        if (headers == null) {
            headers = new Headers.Builder()
                    .add("Content-Type", "application/json")
                    .build();
        }
        final Request request = new Request.Builder()
                .headers(headers)
                .url(url)
                .post(body)
                .build();

        okHttpClient.newCall(request).enqueue(new okhttp3.Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                if (callback != null) {
                    callback.onFailure(-1, e.getMessage());
                }
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                handleResponse(url, call, response, callback);

            }
        });
    }

    public static <T> void post(final String url, Map<String, Object> param, final Callback<T> callback) {
        RequestBody body = RequestBody.create(JSON, gson.toJson(param));
        final Request request = new Request.Builder()
                .url(url)
                .post(body)
                .build();

        okHttpClient.newCall(request).enqueue(new okhttp3.Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                if (callback != null) {
                    callback.onFailure(-1, e.getMessage());
                }
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                handleResponse(url, call, response, callback);

            }
        });
    }

    public static <T> void put(final String url, Map<String, String> param, final Callback<T> callback) {
        RequestBody body = RequestBody.create(JSON, gson.toJson(param));
        final Request request = new Request.Builder()
                .url(url)
                .put(body)
                .build();

        okHttpClient.newCall(request).enqueue(new okhttp3.Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                if (callback != null) {
                    callback.onFailure(-1, e.getMessage());
                }
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                handleResponse(url, call, response, callback);

            }
        });
    }

    public static <T> void upload(final String url, Map<String, String> params, File file, MediaType mediaType, final Callback<T> callback) {
        MultipartBody.Builder builder = new MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart("file", file.getName(),
                        RequestBody.create(mediaType, file));

        if (params != null) {
            for (Map.Entry<String, String> entry : params.entrySet()) {
                builder.addFormDataPart(entry.getKey(), entry.getValue());
            }
        }

        RequestBody requestBody = builder.build();

        Request request = new Request.Builder()
                .url(url)
                .post(requestBody)
                .build();
        okHttpClient.newCall(request).enqueue(new okhttp3.Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                if (callback != null) {
                    callback.onFailure(-1, e.getMessage());
                }
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                handleResponse(url, call, response, callback);
            }
        });
    }

    public static <T> RespResult<T> fromJsonObject(String reader, Class<T> clazz) {
        Type type = new UserParameterizedType(RespResult.class, new Class[]{clazz});
        return gson.fromJson(reader, type);
    }


    private static <T> void handleResponse(String url, Call call, Response response, Callback<T> callback) {
        if (callback != null) {
            if (!response.isSuccessful()) {
                callback.onFailure(response.code(), response.message());
                return;
            }
            Type[] types = callback.getClass().getGenericInterfaces();
            Type type = ((ParameterizedType) types[0]).getActualTypeArguments()[0];
            try {
                UserParameterizedType userParameterizedType =
                        new UserParameterizedType(RespResult.class, new Class[]{(Class<T>) type});
                ResponseBody body = response.body();
                if (body == null) {
                    callback.onFailure(-1, "response body is null!");
                    return;
                }
                String resultStr = body.string();
                RespResult<T> respResult = gson.fromJson(resultStr, userParameterizedType);
                if (respResult.isSuccess()) {
                    callback.onSuccess(respResult.getData());
                } else {
                    callback.onFailure(respResult.getCode(), respResult.getMessage());
                }
            } catch (Exception e) {
                e.printStackTrace();
                callback.onFailure(-1, e.getMessage());
            }
        }
    }
}
