Here is the comprehensive **`PREREQUISITES.md`** file.

This document serves as the "Day 1 Setup Guide" for any engineer joining the Bio AI team. It covers physical hardware requirements, local software installation, and the external accounts needed for both development and production.

---

# **📋 System Prerequisites & Setup Guide**

**Project:** Bio AI - Bio-Adaptive Nutrition Engine
**Version:** 1.0.0

This document outlines the hardware, software, and cloud accounts required to build, run, and deploy Bio AI.

---

## **1. Hardware Requirements**

Because this architecture relies on a microservices mesh (running MongoDB, Postgres, Redis, MinIO, and Python services simultaneously), a robust local machine is required.

- **Operating System:**
    - macOS (M1/M2/M3 Silicon recommended)
    - Linux (Ubuntu 22.04 LTS+)
    - Windows 11 (Must use **WSL2**; Native Windows is not supported for the backend).
- **RAM:** Minimum **16GB** (32GB recommended).
- **Disk:** 50GB free space (Docker images + ML Models).
- **GPU (Optional):**
    - If you want to run the Vision Pipeline locally with acceleration, an NVIDIA GPU (RTX 3060+) with CUDA 12.x support is required.
    - _Note:_ Apple Silicon (Metal) support is available but slower than CUDA.

---

## **2. Local Development Environment**

Install these tools in the order listed.

### **A. Core Infrastructure (Containerization)**

We do not install databases directly on the host machine. We use Docker.

1.  **Docker Desktop (or OrbStack on Mac):**
    - Download: [Docker Website](https://www.docker.com/products/docker-desktop/)
    - **Requirement:** Ensure "Use Docker Compose V2" is enabled.
2.  **AWS CLI v2:**
    - Even for local development, we use this to interact with MinIO (our local S3).
    - Install: `brew install awscli` (Mac) or `sudo apt install awscli` (Linux).
3.  **Terraform (OpenTofu):**
    - Required if you plan to touch the `infra/` folder.
    - Install: `brew install opentofu`.

### **B. Backend Stack (Python)**

We use **Poetry** for dependency management to ensure deterministic builds.

1.  **Python 3.11:**
    - We strictly use version 3.11.x.
    - Manager: Recommended to use `pyenv` to manage versions.
2.  **Poetry:**
    - Install: `curl -sSL https://install.python-poetry.org | python3 -`
    - Config: Run `poetry config virtualenvs.in-project true` (Keeps venvs inside the project folder).

### **C. Frontend Stack (Mobile)**

1.  **Flutter SDK:**
    - Version: **Stable Channel** (3.19+).
    - Install: [Flutter Install Guide](https://docs.flutter.dev/get-started/install).
2.  **Android Studio (for Android Dev):**
    - Install "Android SDK Command-line Tools" and "CMake" via SDK Manager.
    - Create a Virtual Device (Pixel 6 or newer).
3.  **Xcode (for iOS Dev - Mac Only):**
    - Install via Mac App Store.
    - Run `xcode-select --install` to get command line tools.
    - Run `sudo xcodebuild -license` to accept terms.

---

## **3. Cloud Infrastructure Accounts**

While you can develop locally for free, you will need these accounts to deploy or test the "Real" AI pipelines.

### **A. Cloud Provider (AWS)**

_Used for: Production Hosting (EKS), Storage (S3), Database (RDS)._

1.  **Create Account:** [aws.amazon.com](https://aws.amazon.com/)
2.  **IAM User:** Create a user named `bio-ai-admin` with `AdministratorAccess`.
3.  **Credentials:** Generate an Access Key ID and Secret Access Key.
4.  **Local Setup:** Run `aws configure` and input these keys.

### **B. GPU Compute (RunPod)**

_Used for: Serverless GPU Inference (The "Dragunov" Vision System)._

1.  **Create Account:** [runpod.io](https://runpod.io/)
2.  **Add Funds:** Deposit ~$10 (Minimum) for testing.
3.  **API Key:** Generate a key under Settings > API Keys.
4.  **Network Volume:** Create a Network Volume (10GB) if persistent model caching is needed.

### **C. AI Model APIs**

_Used for: The "Bio-Adaptive" Agent Logic._

1.  **OpenAI:**
    - Create account at `platform.openai.com`.
    - Generate API Key.
    - Ensure you have credits (Free tier often has rate limits that break the app).
2.  **Anthropic (Optional Fallback):**
    - Create account at `console.anthropic.com`.
    - Generate API Key for Claude 3.5 Sonnet.

### **D. Geo-Spatial Data**

_Used for: Restaurant Menu Lookup._

1.  **Google Cloud Platform:**
    - Enable **Places API (New)**.
    - Generate API Key.
    - _Restriction:_ Restrict this key to your Android/iOS Bundle IDs.

---

## **4. Authentication & Security**

### **A. Social Login Providers**

To test "Sign in with Google/Apple" on the device:

1.  **Firebase Console (Proxy):**
    - Create a project `bio-ai-dev`.
    - Enable Authentication > Sign-in method > Google.
    - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
2.  **Apple Developer Account:**
    - Required for "Sign in with Apple" capability.
    - Cost: $99/year (Only needed for actual App Store deployment/TestFlight).

---

## **5. Environment Configuration**

You must create a `.env` file in the root of the monorepo.
**DO NOT COMMIT THIS FILE.**

```ini
# --- GLOBAL ---
ENV=development
PROJECT_NAME="Bio AI"

# --- INFRASTRUCTURE (Local Docker) ---
# We use standard internal Docker DNS names
MONGO_URI="mongodb://mongo:27017"
REDIS_URL="redis://redis:6379/0"
POSTGRES_URI="postgresql://postgres:postgres@postgres:5432/bio_auth"

# --- STORAGE (MinIO acting as S3) ---
AWS_ACCESS_KEY_ID="minioadmin"
AWS_SECRET_ACCESS_KEY="minioadmin"
AWS_REGION="us-east-1"
S3_ENDPOINT_URL="http://localhost:9000"
S3_BUCKET_RAW="bio-ai-raw"
S3_BUCKET_GALLERY="bio-ai-gallery"

# --- EXTERNAL APIs (Fill these to make AI work) ---
OPENAI_API_KEY="sk-proj-..."
RUNPOD_API_KEY="rpa_..."
GOOGLE_PLACES_KEY="AIza..."

# --- SECURITY ---
# Run `openssl rand -hex 32` to generate these
JWT_SECRET="generate_a_secure_random_string_here"
AUTH_PRIVATE_KEY_PATH="./certs/private.pem"
AUTH_PUBLIC_KEY_PATH="./certs/public.pem"
```

---

## **6. Verification Checklist**

Before writing code, run these sanity checks to ensure your machine is ready.

**1. Check Docker:**

```bash
docker run hello-world
# Output: "Hello from Docker!"
```

**2. Check Python/Poetry:**

```bash
poetry --version
# Output: Poetry (version 1.7+)
```

**3. Check Flutter:**

```bash
flutter doctor
# Output: Should show ticks for Android toolchain and Chrome.
```

**4. Check AWS/MinIO Config:**

```bash
# Ensure local MinIO is running first (docker-compose up)
aws s3 ls --endpoint-url http://localhost:9000
# Output: (Empty list or bucket list, no errors)
```

**5. Check GPU (If Linux/Windows):**

```bash
nvidia-smi
# Output: Should show your GPU Name and Driver Version.
```

---

## **7. First-Time Boot**

Once prerequisites are installed, boot the entire local stack:

```bash
# 1. Clone Repo
git clone https://github.com/your-org/bio-ai.git
cd bio-ai

# 2. Generate Certs (for Auth)
mkdir -p bio_auth/certs
openssl genrsa -out bio_auth/certs/private.pem 2048
openssl rsa -in bio_auth/certs/private.pem -pubout -out bio_auth/certs/public.pem

# 3. Install Python Dependencies
cd bio_ai_server && poetry install
cd ../bio_inference && poetry install

# 4. Start Infrastructure
docker-compose up -d --build

# 5. Verify
# Visit http://localhost:8080/docs (BFF Swagger)
# Visit http://localhost:9001 (MinIO Console)
```
