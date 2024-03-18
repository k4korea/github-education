FROM node:7-onbuild

WORKDIR /usr/src/app
# set a health check
HEALTHCHECK --interval=5s \
            --timeout=5s \
CMD curl -f http://127.0.0.1:80 || exit 1

# tell docker what port to expose
#CMD [ "node ./index.js" ]
#ENTRYPOINT [  "node index.js" ]

### virtlet front ####
EXPOSE 80
CMD [ "node", "index.js" ]