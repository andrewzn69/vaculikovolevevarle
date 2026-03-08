## build runner
FROM node:lts-alpine as build-runner

# set temp directory
WORKDIR /tmp/app

# install pnpm
RUN npm install -g pnpm

# copy dependency files
COPY package.json pnpm-lock.yaml ./
COPY patches ./patches

# install dependencies
RUN pnpm install --frozen-lockfile

# move source files
COPY src ./src
COPY tsconfig.json   .

# build project
RUN pnpm run build

## production runner
FROM node:lts-alpine as prod-runner

# set work dir
WORKDIR /app

# install pnpm
RUN npm install -g pnpm

# copy package files and patches from build-runner
COPY --from=build-runner /tmp/app/package.json /app/package.json
COPY --from=build-runner /tmp/app/pnpm-lock.yaml /app/pnpm-lock.yaml
COPY --from=build-runner /tmp/app/patches /app/patches

# install production deps
RUN pnpm install --frozen-lockfile --prod

# move build files
COPY --from=build-runner /tmp/app/build /app/build

# start bot
CMD [ "pnpm", "run", "start" ]
