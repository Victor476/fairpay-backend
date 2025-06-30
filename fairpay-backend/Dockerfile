FROM eclipse-temurin:21-jdk-alpine as build

WORKDIR /app

# Copiar arquivos do projeto
COPY mvnw pom.xml ./
COPY .mvn .mvn
RUN chmod +x ./mvnw
RUN ./mvnw dependency:go-offline -B

# Copiar código fonte e compilar
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Imagem final otimizada
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copiar o JAR compilado
COPY --from=build /app/target/*.jar app.jar

# Variáveis de ambiente (podem ser sobrescritas no docker-compose)
ENV SPRING_PROFILES_ACTIVE=prod
ENV SERVER_PORT=8090

# Expor a porta do Spring Boot
EXPOSE 8090

# Comando para iniciar a aplicação
ENTRYPOINT ["java", "-jar", "app.jar"]