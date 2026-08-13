allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// receive_sharing_intent 1.9.0 usa el bloque `kotlin { compilerOptions { … } }`
// pero su build.gradle no aplica el plugin de Kotlin: da por supuesto AGP 9.x,
// que ya lo trae integrado. Este proyecto usa el AGP 8.11.1 que genera Flutter
// 3.41.6, así que hay que aplicárselo nosotros.
//
// Se puede borrar cuando el proyecto suba a AGP 9.
// receive_sharing_intent 1.8.1 declara jvmTarget 1.8 mientras el proyecto
// compila con 21, y Gradle aborta por la incoherencia. Se unifica a 17.
//
// PROVISIONAL: existe sólo porque estamos anclados a 1.8.1. La versión 1.9.0
// no necesita este parche, pero exige AGP 9.x — ver §16 del plan. Ambos, este
// bloque y el anclaje, desaparecen cuando el proyecto suba a AGP 9.
subprojects {
    plugins.withId("org.jetbrains.kotlin.android") {
        extensions.configure<org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension> {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
