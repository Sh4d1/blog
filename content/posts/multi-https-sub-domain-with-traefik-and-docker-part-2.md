---
title: "Multi HTTPS sub domain with Traefik and Docker - Part 2"
date: 2017-10-08
type: ["posts","post"]
author:
  name: Patrik Cyvoct
tags:
  - traefik
  - docker
  - https
aliases:
  - /multi-https-sub-domain-with-traefik-and-docker-part-2
---
In this (small) second part, we'll set up Traefik Web UI on its own sub domain with a basic HTTP authentication. 

## Basic dashboard

In the `traefik.toml` we add the following just before the `[entryPoints]` label: 
```toml
[web]
# Port for the status page
address = ":8080"
```
We also need to map the port 8080 in the `docker-compose.yml` so you have to add this line in the ports section:
```
- 8080:8080
```
Now we can access Traefik Web UI at `yourdomain.com:8080`. It will look like this:

![Traefik's dashboard](/images/dashboard-1.png)

## Let's add a sub domain

Now we need to modify the `docker-compose.yml` in order to redirect to a sub domain. The only thing we are going to add is the Docker labels:
* `"traefik.enabled=true"`
* `"traefik.backend=dashboard"`
* `"traefik.frontend.rule=Host:dashboard.yourdomain.com"`
* `"traefik.port=8080"`

Moreover, we don't need to map the port 8080 since we will not access the dashboard through this port. 

So our file will look like this:
```yaml
version: '2'
services:
    traefik:
    image: traefik
    command: --web --docker
    ports:
      - "80:80"
      - "443:443"
    restart: always
    labels:
      - "traefik.enabled=true"
      - "traefik.backend=dashboard"
      - "traefik.frontend.rule=Host:dashboard.yourdomain.com"
      - "traefik.port=8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock" 
      - "./traefik.toml:/traefik.toml"
      - "./acme.json:/acme.json"
    networks:
      - default 
```

Now you can access your dashboard through the desired URL!

## A basic HTTP authentication

If you need to protect your application with a user/password authentication, Traefik can do it for you. Again it's configurable via the Docker labels of the service:
`traefik.frontend.auth.basic=user:passwordHash`
You can get the hash with the htpasswd command like this
```
$ htpasswd -nB user
New password:
Re-type new password:
user:$2y$05$NiscFUPxmLub5vW1gL6cF.4R1ElHKeMgBQKNPIY.1V.CW802nXhwG
```

When you add the hash in the `docker-compose.yml` you must escape the `$` character with another `$`. In this case we will have : 
`traefik.frontend.auth.basic=user:$$2y$$05$$NiscFUPxmLub5vW1gL6cF.4R1ElHKeMgBQKNPIY.1V.CW802nXhwG`. Your application will then be protected by a user/password authentication.

You can now easily access your public and private Docker applications through different sub domains.
