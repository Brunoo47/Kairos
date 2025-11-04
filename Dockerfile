# Etapa 1 — Build da aplicação com Gradle
FROM eclipse-temurin:21-jdk AS build

WORKDIR /app

# Copia os arquivos de configuração primeiro (melhor aproveitamento do cache)
COPY gradlew build.gradle.kts settings.gradle.kts ./
COPY gradle gradle

# Dá permissão de execução pro gradlew
RUN chmod +x gradlew

# Baixa dependências (cache do Gradle)
RUN ./gradlew dependencies --no-daemon

# Copia o código-fonte
COPY src src

# Builda o JAR final (sem rodar testes)
RUN ./gradlew clean bootJar --no-daemon

# Etapa 2 — Imagem final leve para rodar o app
FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app

# Copia o JAR gerado da etapa anterior
COPY --from=build /app/build/libs/*.jar app.jar

# Expõe a porta padrão do Spring Boot
EXPOSE 8080

# Comando para rodar o app
ENTRYPOINT ["java", "-jar", "app.jar"]
