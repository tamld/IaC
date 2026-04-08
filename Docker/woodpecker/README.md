<div align="center">

<pre>
__        __               _                 _             
\ \      / /__   ___   __| |_ __   ___  ___| | _____ _ __ 
 \ \ /\ / / _ \ / _ \ / _` | '_ \ / _ \/ __| |/ / _ \ '__|
  \ V  V / (_) | (_) | (_| | |_) |  __/ (__|   <  __/ |   
   \_/\_/ \___/ \___/ \__,_| .__/ \___|\___|_|\_\___|_|   
                           |_|                            
</pre>

# Woodpecker CI: Lightning Fast Pipelines

[![Golang](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)](#)

*CI/CD shouldn't take longer to configure than your actual code.*

</div>

---

## 🛑 CI/CD Over-Engineering is Killing Productivity.

**Problem:** You wrote your code, you pushed it to Gitea or GitHub. But enterprise CI solutions like Jenkins require Groovy pipelines, JVM tuning, and plugin dependency hell.
**Solution:** **Woodpecker CI**. A drop-in, ridiculously fast CI/CD engine originally based on Drone. It uses a clean, intuitive YAML format (`.woodpecker.yml`). Every single step is just a Docker container.

---

## 🗺️ ASCII Architecture Flow
*See how asynchronous webhooks trigger automated test containers.*

```text
  [ Developer ]
       | (git push)
       v
+--------------+     (Webhook event)     +-------------------+
|  Gitea Repo  | ----------------------> | Woodpecker Server |
+--------------+                         +-------------------+
       |                                          | (Dispatches Job)
       | (Reports Status)                         v
       |                                 +-------------------+
       |                                 | Woodpecker Agent  |
       |<------------------------------- | (Runner Daemon)   |
                                         +-------------------+
                                                  |
                                                  v
                     [ Clone Container ] -> [ Test Container ] -> [ Deploy Container ]
```

---

## 🛤️ The First-Time User Workflow
Woodpecker connects to your code forge via OAuth. Setting up this link is the hardest part.

1. **Phase 1: The Code Forge OAuth**
   Log into Gitea (or GitHub). Go to Settings -> Applications. Create a new OAuth2 Application. The Redirect URI MUST be `https://woodpecker.domain.com/authorize`. Take the `Client ID` and `Client Secret` generated.

2. **Phase 2: The Core Config**
   Open `.env`. Generate a random 32-character string for `WOODPECKER_AGENT_SECRET`. This is how your agents securely talk to the server over gRPC. Enter the OAuth credentials from Phase 1.

3. **Phase 3: The Deployment**
   ```bash
   docker compose up -d
   ```
   This will bring up the master server AND your worker agent simultaneously.

4. **Phase 4: Run a Pipeline**
   Go to `https://woodpecker.domain.com`. Click "Login", and it will bounce you through Gitea to authenticate. Add a repository. Push a `.woodpecker.yml` file to the root of your repo. The agent will pull the code and run your tests immediately!

---