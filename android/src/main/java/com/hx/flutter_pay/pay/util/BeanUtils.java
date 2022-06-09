package com.hx.flutter_pay.pay.util;



import com.gdhuanyan.pay.model.NeedIterative;
import com.gdhuanyan.pay.model.NotConvert;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.LinkedHashMap;
import java.util.Map;


public class BeanUtils {
    /**
     * map 转object
     *
     * @param map
     * @param beanClass
     * @param <T>
     * @return
     * @throws Exception
     */
    public static <T> T mapToObject(Map map, Class<T> beanClass) throws Exception {
        if (map == null) {
            return null;
        }
        T obj = beanClass.newInstance();
        Field[] fields = obj.getClass().getDeclaredFields();
        for (Field field : fields) {
            int mod = field.getModifiers();
            if (Modifier.isStatic(mod) || Modifier.isFinal(mod)) {
                continue;
            }
            field.setAccessible(true);
            if (map.containsKey(field.getName())) {
                //解决flutter 没有区分long类型的处理
                Object fv = map.get(field.getName());
                if (fv != null && field.getType() == Long.class && fv instanceof Integer) {
                    fv = ((Integer) fv).longValue();
                }
                if (fv instanceof Map && field.getType() != Map.class) {
                    fv = mapToObject((Map) fv, field.getType());
                }
                field.set(obj, fv);

            }
        }
        return obj;
    }


    //Object转Map
    public static Map<String, Object> objectToMap(Object obj) throws IllegalAccessException {
        Map<String, Object> map = new LinkedHashMap<String, Object>();
        Class<?> clazz = obj.getClass();
//        System.out.println(clazz);
        for (Field field : clazz.getDeclaredFields()) {
            field.setAccessible(true);
            String fieldName = field.getName();
            Object value = field.get(obj);
            if (value == null) {
                value = "";
            }
            NeedIterative annotation = field.getAnnotation(NeedIterative.class);
            //获取的注解不为空，那么说明此处返回的结果是对象，那么需要迭代处理
            if (annotation != null) {
                value = objectToMap(value);
            }
            NotConvert notConvert = field.getAnnotation(NotConvert.class);
            if (notConvert != null) {
                continue;
            }
            map.put(fieldName, value);
        }
        return map;
    }

}
