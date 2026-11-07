package com.warehouse;

import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

/**
 * 外部 Tomcat 部署入口。
 * <p>
 * 本地 {@code mvn spring-boot:run} / {@code java -jar} 仍然使用内嵌 Tomcat，
 * 这个类只在 WAR 被容器加载时生效。
 */
public class ServletInitializer extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(SmartWarehouseApplication.class);
    }
}
