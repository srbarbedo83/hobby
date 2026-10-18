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

// Plugins antigos (home_widget, share_plus, workmanager_android) ainda usam
// o DSL legado `android.kotlinOptions` com jvmTarget 1.8 fixo no seu
// próprio build.gradle — mas as suas dependências (ex.: coroutines, glance)
// já trazem bytecode compilado com JVM target 11, o que o compilador Kotlin
// rejeita ao fazer inlining. Sobe o jvmTarget desses módulos para 11 via
// reflexão Groovy (`withGroovyBuilder`), evitando depender do tipo
// `KotlinCompile` (que não está no classpath deste script) só para alcançar
// uma propriedade que, nestes módulos, existe. Exclui `:app`, que já define
// o seu jvmTarget (17) pelo DSL novo `compilerOptions`.
subprojects {
    if (name == "app") return@subprojects
    tasks.matching { it.name.contains("compile", ignoreCase = true) && it.name.contains("Kotlin") }
        .configureEach {
            try {
                withGroovyBuilder {
                    getProperty("kotlinOptions").withGroovyBuilder {
                        setProperty("jvmTarget", "11")
                    }
                }
            } catch (_: Exception) {
                // Tarefa sem a propriedade `kotlinOptions` — ignora.
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
