<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>${packageName}</groupId>
        <artifactId>${systemName?uncap_first}-parent</artifactId>
        <version>1.0.0</version>
        <relativePath>../</relativePath>
    </parent>

    <properties>
        <warName>${systemName?uncap_first}${projectName?cap_first}</warName>
    </properties>

    <artifactId>${systemName?uncap_first}-web-${projectName?uncap_first}</artifactId>
    <version>${'${'}systemVersion}</version>
    <packaging>war</packaging>
    <name>7-${systemName?uncap_first}-web-${projectName?uncap_first}</name>
    
    <!-- 不需要springboot请将springboot部分注释 -->
    
    <!--springboot_import-->

    <dependencies>
        <dependency>
            <groupId>${packageName}</groupId>
            <artifactId>${systemName?uncap_first}-web-base</artifactId>
        </dependency>

        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-test</artifactId>
        </dependency>

        <dependency>
            <groupId>org.apache.httpcomponents</groupId>
            <artifactId>httpclient</artifactId>
        </dependency>

        <dependency>
            <groupId>org.apache.httpcomponents</groupId>
            <artifactId>httpmime</artifactId>
        </dependency>




        <dependency>
            <groupId>org.stategen.framework</groupId>
            <artifactId>progen</artifactId>
        </dependency>

		<!--qiniu begin -->
        <dependency>
            <groupId>org.jsoup</groupId>
            <artifactId>jsoup</artifactId>
            <version>1.12.1</version>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>com.qiniu</groupId>
            <artifactId>happy-dns-java</artifactId>
            <version>0.1.4</version>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>com.squareup.okio</groupId>
            <artifactId>okio</artifactId>
            <version>1.13.0</version>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>com.qiniu</groupId>
            <artifactId>qiniu-java-sdk</artifactId>
            <version>7.1.3</version>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.yaml</groupId>
            <artifactId>snakeyaml</artifactId>
            <scope>test</scope>
        </dependency>

    <!--qiniu end -->
    
    <!-- weixin bean -->
        <dependency>
            <groupId>com.github.binarywang</groupId>
            <artifactId>weixin-java-open</artifactId>
        </dependency>

        <dependency>
            <groupId>com.github.binarywang</groupId>
            <artifactId>weixin-java-pay</artifactId>
        </dependency>

        <dependency>
            <groupId>com.github.binarywang</groupId>
            <artifactId>weixin-java-miniapp</artifactId>
        </dependency>

        <dependency>
            <groupId>com.github.binarywang</groupId>
            <artifactId>weixin-java-common</artifactId>
        </dependency>               
		<!-- weixin end -->


               
        <!--springboot_dependencies-->
    </dependencies>



    <build>
        <plugins>
            <plugin>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                    <encoding>UTF-8</encoding>
                </configuration>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-clean-plugin</artifactId>
                <configuration>
                    <failOnError>true</failOnError>
                    <filesets>
                    </filesets>
                </configuration>
            </plugin>

            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>exec-maven-plugin</artifactId>
                <executions>
                <!--APPEND_TAG_DO_NOT_CHANGE-->
                </executions>
            </plugin>

            <plugin>
                <artifactId>maven-war-plugin</artifactId>
                <configuration>
                    <warSourceDirectory>${'${'}basedir}/WebRoot</warSourceDirectory>
                    <failOnMissingWebXml>true</failOnMissingWebXml>
                    <warName>${'${'}warName}</warName>
                    <packagingExcludes>
                        node_modules/**
                    </packagingExcludes>
                </configuration>
            </plugin>

            <plugin>
                <artifactId>maven-deploy-plugin</artifactId>
                <executions>
                    <execution>
                        <id>default-deploy</id>
                        <phase>deploy</phase>
                        <goals>
                            <goal>deploy</goal>
                        </goals>
                        <configuration>
                            <!-- 不发布到maven仓库 -->
                            <skip>true</skip>
                        </configuration>
                    </execution>
                </executions>
            </plugin>

           <!--springboot_plugin--> 
        </plugins>

        <pluginManagement>
            <plugins>
                <!--This plugin's configuration is used to store Eclipse m2e settings only. It has no influence on the Maven build itself.-->
                <plugin>
                    <groupId>org.eclipse.m2e</groupId>
                    <artifactId>lifecycle-mapping</artifactId>
                    <version>1.0.0</version>
                    <configuration>
                        <lifecycleMappingMetadata>
                            <pluginExecutions>
                                <pluginExecution>
                                    <pluginExecutionFilter>
                                        <groupId>org.codehaus.mojo</groupId>
                                        <artifactId>exec-maven-plugin</artifactId>
                                        <versionRange>[1.6.0,)</versionRange>
                                        <goals>
                                            <goal>java</goal>
                                            <goal>exec</goal>
                                        </goals>
                                    </pluginExecutionFilter>
                                    <action>
                                        <ignore></ignore>
                                    </action>
                                </pluginExecution>
                            </pluginExecutions>
                        </lifecycleMappingMetadata>
                    </configuration>
                </plugin>
            </plugins>
        </pluginManagement>
    </build>
</project>