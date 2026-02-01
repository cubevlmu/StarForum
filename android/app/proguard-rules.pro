########################################
# Flutter / Dart
########################################
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

########################################
# Dio / OkHttp / Network
########################################
-keep class dio.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

########################################
# Cookie / Cache
########################################
-keep class com.github.franmontiel.** { *; }   # cookie_jar / dio_cookie_manager
-keep class io.flutter.plugins.pathprovider.** { *; }

########################################
# Drift / SQLite
########################################
-keep class drift.** { *; }
-keep class sqlite3.** { *; }
-keep class org.sqlite.** { *; }

-keep class * extends drift.Table { *; }
-keep class * extends drift.DataClass { *; }
-keep class * extends drift.Database { *; }

########################################
# RxDart
########################################
-keep class io.reactivex.** { *; }
-dontwarn io.reactivex.**

########################################
# HTML parsing
########################################
-keep class org.jsoup.** { *; }
-dontwarn org.jsoup.**

########################################
# CachedNetworkImage / CacheManager
########################################
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

########################################
# Platform plugins
########################################
-keep class io.flutter.plugins.share.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

########################################
# Kotlin Metadata
########################################
-keep class kotlin.Metadata { *; }

########################################
# Logger
########################################
-keep class com.android.tools.** { *; }

-keepattributes Signature
-keepattributes *Annotation*
