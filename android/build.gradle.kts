import com.android.build.gradle.BaseExtension

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

// --- FIX START: We place this BEFORE 'evaluationDependsOn' ---
subprojects {
    afterEvaluate {
        val android = extensions.findByName("android")
        if (android != null) {
            val extension = android as? BaseExtension
            
            // 1. Fix "Namespace not specified" error (AGP 8+)
            if (extension?.namespace == null) {
                extension?.namespace = project.group.toString()
            }

            // 2. Fix "resource android:attr/lStar not found" error
            // This forces old plugins to use a newer Android SDK
            extension?.compileSdkVersion(35)
        }
    }
}
// --- FIX END ---

subprojects {
    // This locks the project, so it must come AFTER our fix block
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}