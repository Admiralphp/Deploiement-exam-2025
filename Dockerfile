# Utiliser l'image officielle Nginx Alpine (légère)
FROM nginx:alpine

# Informations du mainteneur
LABEL maintainer="votre-email@example.com"
LABEL description="CV One Page - DevOps Engineer"
LABEL version="1.0"

# Supprimer la configuration par défaut de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copier les fichiers du CV dans le répertoire web de Nginx
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/

# Copier une configuration Nginx personnalisée (optionnel)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exposer le port 80
EXPOSE 80

# Healthcheck pour vérifier que Nginx fonctionne
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Démarrer Nginx en mode foreground
CMD ["nginx", "-g", "daemon off;"]
