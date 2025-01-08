
use (distribution)[https://distribution.github.io/distribution/about/configuration/#proxy] build registry mirror


```
+-------------------+       +-------------------+       +-------------------+
| Docker Client     |       | Docker Mirror     |       | Docker Hub        |
| (docker pull)     |       | (Registry)        |       | (Upstream)        |
+-------------------+       +-------------------+       +-------------------+
         |                           |                           |
         | 1. pull alpine:latest     |                           |
         |-------------------------->|                           |
         |                           |                           |
         |                           | 2. check local cache      |
         |                           |<------------------------->|
         |                           |                           |
         |                           | 3. cache miss, upstream   |
         |                           |-------------------------->|
         |                           |                           |
         |                           | 4. pull upstream & cache  |
         |                           |<------------------------->|
         |                           |                           |
         | 5. return to the client   |                           |
         |<--------------------------|                           |
         |                           |                           |
         | 6. finish image pull      |                           |
         |                           |                           |
+-------------------+       +-------------------+       +-------------------+
```

step 1.

use generate-sign.sh generate certs:

```bash
$ ./generae-sign.sh mirror.domain.cc 192.168.10.12
```

move generated files to certs folder.

step2. start serivces by docker compose

```bash
$ docker compose up -d
```

> pls check the output log, make sure 'Registry configured as a proxy cache to xxx' is ready

step 3. (on the machine who will pull images)

 3.1 upload crt file, 

 ```bash
 $ mkdir -p /etc/docker/certs.d/mirror.domain.cc/
 # upload mirror.domain.cc.crt to ca.crt
 ```

 3.2 config daemon mirror in /etc/docker/daemon.json

 ```
 "registry-mirrors":["https://mirror.domain.cc"]
 ```

 notes:

 1. should pull without registry domain
    
    eg: our-private-registry.domain.cc/foo/bar:latest

    pull with `docker pull foo/bar:latest`, this will passthrough via mirror and cached after pulled from upstream private registry.

 2. the service only mirror, can not used as a private registry.

 other:

 1. cat generated certs file

 ```bash
 $ openssl x509 -text -noout -in ca.crt
 ```