# Pin to a specific patch version — prevents silent base-image changes
# that could introduce vulnerabilities or break the build.
FROM tomcat:9.0.85-jdk17-temurin

# Remove Tomcat default webapps (manager UI, examples) — attack surfaces
# that serve no purpose in a production container.
RUN rm -rf /usr/local/tomcat/webapps/*

# Create a non-root user. Running as root inside a container means that
# any exploit grants the attacker root — limiting this to a regular user
# reduces the blast radius significantly.
RUN groupadd --gid 1000 appgroup && \
    useradd --uid 1000 --gid appgroup --shell /bin/sh --create-home appuser

# Copy the WAR artifact with correct ownership
COPY --chown=appuser:appgroup app/ROOT.war /usr/local/tomcat/webapps/ROOT.war

# Fix ownership on Tomcat runtime directories
RUN chown -R appuser:appgroup /usr/local/tomcat

USER appuser

EXPOSE 8080

# Docker marks the container unhealthy if this check fails 3 times.
HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

CMD ["catalina.sh", "run"]
