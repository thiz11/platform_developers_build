<#--
 Copyright 2013 The Android Open Source Project

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
buildscript {
    repositories {
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:0.8.+'
    }
}

apply plugin: 'android'

<#if sample.repository?has_content>
repositories {
<#list sample.repository as rep>
    ${rep}
</#list>
}
</#if>

dependencies {

<#if !sample.auto_add_support_lib?has_content || sample.auto_add_support_lib == "true">
    // Add the support lib that is appropriate for SDK ${sample.minSdk}
  <#if sample.minSdk?number < 7>
    compile "com.android.support:support-v4:19.0.+"
  <#elseif sample.minSdk?number < 13>
    compile "com.android.support:support-v4:19.0.+"
    compile "com.android.support:gridlayout-v7:19.0.+"
  <#else>
    compile "com.android.support:support-v13:19.0.+"
  </#if>

</#if>

<#list sample.dependency as dep>
    compile "${dep}"
</#list>
<#list sample.dependency_external as dep>
    compile files(${dep})
</#list>
}

// The sample build uses multiple directories to
// keep boilerplate and common code separate from
// the main sample code.
List<String> dirs = [
    'main',     // main sample code; look here for the interesting stuff.
    'common',   // components that are reused by multiple samples
    'template'] // boilerplate code that is generated by the sample template process

android {
     <#-- Note that target SDK is hardcoded in this template. We expect all samples
          to always use the most current SDK as their target. -->
    compileSdkVersion ${compile_sdk}

    buildToolsVersion "19.0.1"

    sourceSets {
        main {
            dirs.each { dir ->
<#noparse>
                java.srcDirs "src/${dir}/java"
                res.srcDirs "src/${dir}/res"
</#noparse>
            }
        }
        instrumentTest.setRoot('tests')
        instrumentTest.java.srcDirs = ['tests/src']

<#if sample.defaultConfig?has_content>
        defaultConfig {
        ${sample.defaultConfig}
        }
<#else>
</#if>
    }
}
// BEGIN_EXCLUDE
// Tasks below this line will be hidden from release output

task preflight (dependsOn: parent.preflight) {
    project.afterEvaluate {
        // Inject a preflight task into each variant so we have a place to hook tasks
        // that need to run before any of the android build tasks.
        //
        android.applicationVariants.each { variant ->
        <#noparse>
            tasks.getByPath("prepare${variant.name.capitalize()}Dependencies").dependsOn preflight
        </#noparse>
        }
    }
}

// END_EXCLUDE
