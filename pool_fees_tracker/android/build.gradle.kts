allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // O plugin home_widget declara `androidx.glance:glance-appwidget:1.+`
    // sem fixar versão — isto resolve para uma alpha recente que exige
    // compileSdk 37 (ainda não disponível no Android SDK usado por
    // `flutter.compileSdkVersion`). Fixar a última versão estável evita o
    // problema sem precisar de alterar o plugin. Aplicado a `allprojects`
    // (não só a `:app`) porque é o próprio módulo `:home_widget` que resolve
    // esta dependência na sua compilação.
    configurations.all {
        resolutionStrategy {
            force("androidx.glance:glance:1.1.1")
            force("androidx.glance:glance-appwidget:1.1.1")
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
