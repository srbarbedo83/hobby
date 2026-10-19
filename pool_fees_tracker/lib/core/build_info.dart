/// Identificador visível (Definições → fundo do ecrã) para confirmar que o
/// APK instalado no telemóvel é mesmo o mais recente, sem ambiguidade —
/// atualiza este texto sempre que fizeres um build novo via CI. Nenhuma
/// dependência nova (ex.: package_info_plus) de propósito: é só uma
/// constante, zero risco de voltar a rebentar o Gradle.
const String appBuildLabel = 'v1.0.1+2 — erro do subgraph visível na UI';
