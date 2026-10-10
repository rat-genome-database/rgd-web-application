# RGD Curation Tool Configuration Guide

## Overview
The RGD Curation Tool uses Spring's property-based configuration with support for multiple environments.

## Configuration Files

### Base Configuration
- `application.properties` - Default settings for all environments

### Environment-Specific Configuration
- `application-development.properties` - Development environment settings
- `application-test.properties` - Test environment settings  
- `application-production.properties` - Production environment settings

## Setting Active Profile

### Option 1: System Property
```bash
java -Dspring.profiles.active=production -jar rgd-web-application.war
```

### Option 2: Environment Variable
```bash
export SPRING_PROFILES_ACTIVE=production
```

### Option 3: Application Server Configuration
In Tomcat's `catalina.properties` or `setenv.sh`:
```bash
JAVA_OPTS="$JAVA_OPTS -Dspring.profiles.active=production"
```

## Key Configuration Properties

### Database Connection
- Production uses JNDI: `java:comp/env/jdbc/carpe`
- Development can use direct connection with HikariCP

### Ollama API
- URL: `ollama.api.url`
- Model: `ollama.api.model`
- Timeouts: `ollama.api.timeout.connect`, `ollama.api.timeout.read`

### File Upload
- Max file size: 50MB (configurable)
- Temporary directory: `curation.temp.dir`

### Logging
- Configuration file: `log4j2-curation.xml`
- Log levels configured per environment

## Integration Points

### Existing RGD Application
- Uses same JNDI datasource
- Integrates with existing Spring context
- Compatible with current authentication

### External Services
- Ollama API endpoint must be accessible
- Ontology files must be available at configured paths

## Security Considerations
- Never commit production passwords
- Use environment variables for sensitive data
- Enable security headers in production

## Troubleshooting

### Database Connection Issues
1. Check JNDI configuration in application server
2. Verify Oracle driver is in classpath
3. Test connection with development properties

### Ollama API Issues
1. Verify API endpoint is accessible
2. Check timeout settings
3. Review API logs in `ollama-api.log`

### File Upload Issues
1. Ensure temp directory exists and is writable
2. Check file size limits
3. Verify multipart resolver configuration