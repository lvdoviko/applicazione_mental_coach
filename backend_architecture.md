# AI Wellbeing Coach - Backend Architecture

## Overview

The AI Wellbeing Coach backend is designed as a microservices architecture optimized for scalability, cost-efficiency, and GDPR compliance. The system supports real-time chat with AI coaching, health data integration, and human escalation workflows.

## High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Mobile Apps   │    │   Web Portal    │    │   Admin Panel   │
│  (iOS/Android)  │    │  (Future MVP+)  │    │ (Coach Portal)  │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────┬───────────────────────────────┘
                         │
          ┌──────────────▼─────────────────┐
          │         API Gateway            │
          │    (Rate Limiting, Auth,       │
          │     Load Balancing)            │
          └──────────────┬─────────────────┘
                         │
          ┌──────────────▼─────────────────┐
          │        Load Balancer           │
          │      (Application Layer)       │
          └──┬───────────┬─────────────────┘
             │           │
    ┌────────▼───┐   ┌───▼──────┐   ┌─────────────┐
    │    Auth    │   │   Chat   │   │ User/Health │
    │  Service   │   │ Service  │   │   Service   │
    └────────────┘   └────┬─────┘   └─────┬───────┘
                          │               │
             ┌────────────▼─────────────┬─▼─────────────┐
             │                        │               │
    ┌────────▼───────┐    ┌──────────▼───────┐  ┌────▼─────┐
    │ RAG/AI Engine  │    │  Vector Database │  │  Cache   │
    │   Orchestrator │    │   (Embeddings)   │  │ (Redis)  │
    └────┬───────────┘    └──────────────────┘  └──────────┘
         │
    ┌────▼─────┐    ┌──────────────┐    ┌─────────────┐
    │   LLM    │    │ Time-series  │    │ Object      │
    │ Provider │    │  Database    │    │ Storage     │
    │(OpenAI)  │    │(InfluxDB)    │    │   (S3)      │
    └──────────┘    └──────────────┘    └─────────────┘
```

## Core Services

### 1. API Gateway
**Technology**: Kong or AWS API Gateway
**Responsibilities**:
- Request routing and load balancing
- Rate limiting (100 req/day free, 20 chat/hour)
- Authentication & authorization
- Request/response logging
- CORS handling
- API versioning

**Rate Limiting Strategy**:
```yaml
Tiers:
  - Free: 100 requests/day, 20 chat messages/hour
  - Premium: 1000 requests/day, 100 chat messages/hour
  - Team: 5000 requests/day, 500 chat messages/hour

Quotas reset: Daily at midnight UTC
Overflow handling: Queue + graceful degradation
```

### 2. Authentication Service
**Technology**: Node.js + JWT + bcrypt
**Database**: PostgreSQL
**Responsibilities**:
- User registration and login
- JWT token management (15min access, 7d refresh)
- Password reset flows
- GDPR consent tracking
- Account deletion workflows

**Security Features**:
- bcrypt password hashing (rounds: 12)
- Rate limiting: 5 login attempts per IP/10min
- Email verification required
- 2FA support (future enhancement)

### 3. Chat Service
**Technology**: Node.js + WebSocket (Socket.io)
**Responsibilities**:
- Real-time chat management
- Message persistence and retrieval
- Session management
- Typing indicators
- Message delivery status
- Context preservation between sessions

**Message Flow**:
```
User Message → Validation → Context Enrichment → RAG Orchestrator → AI Response → Context Update → User
```

### 4. RAG Orchestration Engine
**Technology**: Python + LangChain + FastAPI
**Responsibilities**:
- Query preprocessing and context building
- Vector database retrieval
- LLM prompt engineering and response generation
- Response post-processing
- Cost optimization (model selection)
- Response caching

**Cost Optimization Strategy**:
```python
# Tiered Model Selection
def select_model(query_complexity, user_tier):
    if query_complexity < 0.3 and user_tier == 'free':
        return 'gpt-3.5-turbo'  # $0.002/1K tokens
    elif query_complexity < 0.7:
        return 'gpt-4-turbo'    # $0.01/1K tokens  
    else:
        return 'gpt-4'          # $0.03/1K tokens

# Response Caching
cache_key = hash(query + context + user_preferences)
if cached_response := redis.get(cache_key):
    return cached_response  # Save ~80% on repeat queries
```

### 5. User & Health Service
**Technology**: Node.js + Express
**Databases**: PostgreSQL (user data) + InfluxDB (time-series health data)
**Responsibilities**:
- User profile management
- Health data integration (HealthKit/Health Connect)
- Avatar configuration storage
- Analytics data aggregation
- GDPR data export/deletion

**Health Data Integration**:
```javascript
// Apple HealthKit Integration
const healthTypes = [
  'HKQuantityTypeIdentifierStepCount',
  'HKQuantityTypeIdentifierHeartRate', 
  'HKCategoryTypeIdentifierSleepAnalysis',
  'HKQuantityTypeIdentifierActiveEnergyBurned',
  'HKWorkoutTypeIdentifier'
];

// Privacy: End-to-end encryption for health data
encrypt(healthData, user_key) -> encrypted_payload
```

### 6. Escalation & Support Service
**Technology**: Node.js + Express + Email (SendGrid) + Webhook integrations
**Responsibilities**:
- Human coach escalation requests
- Support ticket management  
- Emergency support routing
- Coach assignment and availability
- SLA tracking and notifications

**Escalation Workflow**:
```
User Request → Priority Assessment → Coach Assignment → Notification → Response Tracking
```

## Database Architecture

### PostgreSQL (Primary Database)
**Schema Design**:
```sql
-- Users table with GDPR compliance
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    sport VARCHAR(50),
    team VARCHAR(100),
    role user_role_enum,
    avatar_config JSONB,
    preferences JSONB,
    consent_data_processing BOOLEAN DEFAULT false,
    consent_health_data BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE NULL -- Soft delete for GDPR
);

-- Chat sessions
CREATE TABLE chat_sessions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    message_count INTEGER DEFAULT 0,
    session_summary TEXT,
    context JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages with encryption
CREATE TABLE messages (
    id UUID PRIMARY KEY,
    session_id UUID REFERENCES chat_sessions(id),
    user_id UUID REFERENCES users(id),
    content_encrypted TEXT NOT NULL, -- AES-256 encrypted
    message_type message_type_enum,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status message_status_enum,
    context JSONB
);

-- Audit log for GDPR compliance
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Vector Database (Pinecone/Weaviate)
**Purpose**: Store and retrieve embeddings for RAG
```python
# Index structure
index_config = {
    "dimension": 1536,  # OpenAI embedding dimension
    "metric": "cosine",
    "replicas": 2,      # High availability
    "shards": 4         # Horizontal scaling
}

# Metadata structure
metadata = {
    "category": "wellness_advice",
    "sport": "basketball", 
    "topic": "stress_management",
    "source": "expert_knowledge",
    "confidence": 0.95,
    "language": "en"
}
```

### InfluxDB (Time-Series Data)
**Purpose**: Store health metrics and analytics
```sql
-- Health metrics measurement
CREATE MEASUREMENT health_metrics (
    time TIMESTAMP,
    user_id STRING,
    metric_type STRING,
    value FLOAT,
    unit STRING,
    source STRING,
    tags: sport, team, device_type
);

-- Analytics measurement  
CREATE MEASUREMENT user_analytics (
    time TIMESTAMP,
    user_id STRING,
    event_type STRING,
    session_duration INTEGER,
    message_count INTEGER,
    mood_score FLOAT,
    tags: feature, platform, version
);
```

### Redis (Caching & Sessions)
```python
# Caching Strategy
CACHE_KEYS = {
    "user_profile": "user:profile:{user_id}",     # TTL: 1 hour
    "chat_context": "chat:context:{session_id}",  # TTL: 24 hours  
    "ai_response": "ai:response:{query_hash}",    # TTL: 7 days
    "health_data": "health:summary:{user_id}",    # TTL: 30 minutes
    "rate_limit": "rate:limit:{user_id}:{endpoint}" # TTL: 1 hour
}

# Session Management
session_structure = {
    "user_id": "uuid",
    "permissions": ["chat", "health_sync"],
    "tier": "premium",
    "last_activity": "timestamp"
}
```

## Data Contracts

### User Profile Contract
```typescript
interface UserProfile {
  id: string;
  email: string;
  name: string;
  sport?: string;
  team?: string;
  role: 'athlete' | 'coach' | 'team_manager';
  avatar_config: AvatarConfig;
  preferences: UserPreferences;
  consent: {
    data_processing: boolean;
    health_data: boolean;
    marketing: boolean;
  };
  created_at: string;
  last_active: string;
}

interface UserPreferences {
  notifications_enabled: boolean;
  health_data_sync: boolean;
  language: 'en' | 'it';
  privacy_mode: boolean;
  ai_personality: 'empathetic' | 'motivational' | 'analytical';
}
```

### Chat Session Contract
```typescript
interface ChatSession {
  id: string;
  user_id: string;
  started_at: string;
  ended_at?: string;
  messages: Message[];
  context: SessionContext;
  summary?: string;
  mood_progression: MoodEntry[];
}

interface Message {
  id: string;
  content: string;
  type: 'user' | 'ai' | 'system';
  timestamp: string;
  status: 'sending' | 'sent' | 'delivered' | 'read' | 'error';
  metadata?: {
    model_used?: string;
    processing_time?: number;
    confidence_score?: number;
  };
}

interface SessionContext {
  current_mood?: number; // 1-10 scale
  stress_level?: number; // 1-10 scale  
  recent_activities: string[];
  health_metrics?: HealthSummary;
  preferences: ContextPreferences;
}
```

### Health Data Contract
```typescript
interface HealthMetric {
  user_id: string;
  type: 'steps' | 'heart_rate' | 'sleep' | 'workout' | 'mindfulness';
  value: number;
  unit: string;
  timestamp: string;
  source: 'apple_health' | 'google_health' | 'manual';
  device?: string;
}

interface HealthSummary {
  daily_steps: number;
  avg_heart_rate: number;
  sleep_score: number; // 0-100
  workout_minutes: number;
  stress_indicators: {
    hrv: number;
    resting_hr: number;
    sleep_disruptions: number;
  };
}
```

### Escalation Request Contract
```typescript
interface EscalationRequest {
  id: string;
  user_id: string;
  reason: 'needs_human_support' | 'emergency_support' | 'technical_issue' | 'feedback_complaint' | 'general_inquiry';
  urgency: 'low' | 'medium' | 'high' | 'critical';
  message: string;
  context: {
    session_id?: string;
    chat_history_sample?: string;
    recent_mood_scores?: number[];
    health_alerts?: string[];
  };
  status: 'submitted' | 'triaged' | 'assigned' | 'in_progress' | 'responded' | 'closed';
  assigned_coach?: string;
  created_at: string;
  response_time_sla: string; // "4h", "24h", "72h"
}
```

## RAG (Retrieval-Augmented Generation) Flow

### 1. Query Processing Pipeline
```python
def process_query(user_message: str, context: SessionContext) -> AIResponse:
    # Step 1: Query preprocessing
    cleaned_query = preprocess_text(user_message)
    query_embedding = openai.embeddings.create(
        input=cleaned_query,
        model="text-embedding-3-small"  # Cost: $0.00002/1K tokens
    )
    
    # Step 2: Context enrichment
    enriched_context = build_context(
        user_context=context,
        chat_history=get_recent_messages(context.session_id),
        health_data=get_health_summary(context.user_id)
    )
    
    # Step 3: Vector retrieval
    relevant_docs = vector_db.query(
        vector=query_embedding,
        top_k=5,
        filter={
            "sport": context.user_sport,
            "category": classify_query_category(cleaned_query)
        }
    )
    
    # Step 4: Re-ranking
    reranked_docs = rerank_documents(
        query=cleaned_query,
        documents=relevant_docs,
        context=enriched_context
    )
    
    # Step 5: LLM generation
    response = generate_response(
        query=cleaned_query,
        context=enriched_context,
        retrieved_docs=reranked_docs[:3]  # Top 3 for context window
    )
    
    # Step 6: Post-processing & caching
    processed_response = post_process_response(response)
    cache_response(query_hash, processed_response, ttl=7*24*3600)
    
    return processed_response
```

### 2. Knowledge Base Structure
```
knowledge_base/
├── wellness_fundamentals/
│   ├── stress_management/
│   ├── motivation_techniques/
│   ├── performance_anxiety/
│   └── recovery_strategies/
├── sport_specific/
│   ├── basketball/
│   ├── football/
│   ├── tennis/
│   └── individual_sports/
├── emergency_protocols/
│   ├── crisis_intervention/
│   ├── escalation_triggers/
│   └── resource_directories/
└── conversational_patterns/
    ├── empathetic_responses/
    ├── motivational_language/
    └── coaching_techniques/
```

### 3. Prompt Engineering Framework
```python
SYSTEM_PROMPTS = {
    "base": """
    You are an AI wellbeing coach specialized in supporting athletes and sports teams.
    Your responses should be empathetic, supportive, and grounded in sports psychology.
    
    Guidelines:
    - Always validate the user's feelings first
    - Provide actionable, sports-specific advice
    - Know when to escalate to human support
    - Maintain professional boundaries
    - Never provide medical diagnoses
    
    Current context: {context}
    User sport: {sport}
    Recent mood: {mood_score}/10
    """,
    
    "crisis": """
    CRISIS MODE ACTIVATED
    The user may be in distress. Prioritize:
    1. Immediate safety and support
    2. Professional resource recommendations  
    3. Escalation to human coach
    4. Avoid giving specific medical/psychological advice
    
    Emergency contacts: {emergency_contacts}
    """,
    
    "motivational": """
    MOTIVATIONAL MODE
    The user needs encouragement. Focus on:
    - Highlighting past achievements
    - Breaking down goals into manageable steps
    - Sports-specific motivation techniques
    - Building confidence and resilience
    """
}
```

## Cost Optimization Strategies

### 1. AI/LLM Cost Management
```python
# Model Selection Algorithm
def select_optimal_model(query: str, context: dict, user_tier: str) -> str:
    complexity_score = calculate_query_complexity(query)
    context_richness = len(context.get('chat_history', []))
    
    if user_tier == 'free' and complexity_score < 0.4:
        return 'gpt-3.5-turbo'  # $0.002/1K tokens
    elif complexity_score < 0.7 and context_richness < 10:
        return 'gpt-4-turbo'    # $0.01/1K tokens
    else:
        return 'gpt-4'          # $0.03/1K tokens

# Token Optimization
def optimize_prompt(base_prompt: str, context: dict) -> str:
    # Truncate old chat history
    if len(context.get('chat_history', [])) > 10:
        context['chat_history'] = context['chat_history'][-5:]
    
    # Compress context using summarization
    if len(json.dumps(context)) > 4000:  # characters
        context = compress_context(context)
    
    return construct_prompt(base_prompt, context)

# Response Caching
@cached(ttl=7*24*3600)  # 7 days
def get_ai_response(query_hash: str, context_hash: str) -> str:
    # Cache hit saves ~$0.02 per repeat query
    pass
```

### 2. Database Optimization
```sql
-- Partitioning strategy for messages table
CREATE TABLE messages_partitioned (
    LIKE messages INCLUDING ALL
) PARTITION BY RANGE (timestamp);

-- Monthly partitions for better performance
CREATE TABLE messages_2024_01 PARTITION OF messages_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Automatic cleanup of old data
DELETE FROM messages WHERE timestamp < NOW() - INTERVAL '2 years';

-- Indexing strategy  
CREATE INDEX CONCURRENTLY idx_messages_user_timestamp 
    ON messages (user_id, timestamp DESC);
CREATE INDEX CONCURRENTLY idx_messages_session_timestamp
    ON messages (session_id, timestamp DESC);
```

### 3. Infrastructure Cost Management
```yaml
# Auto-scaling configuration
auto_scaling:
  chat_service:
    min_instances: 2
    max_instances: 20
    target_cpu: 70%
    target_memory: 80%
    
  rag_engine:
    min_instances: 1  # Cost-sensitive
    max_instances: 10
    scale_up_cooldown: 300s
    scale_down_cooldown: 900s
    
# Resource requests/limits
resources:
  chat_service:
    requests: { cpu: "100m", memory: "256Mi" }
    limits: { cpu: "500m", memory: "512Mi" }
    
  rag_engine:
    requests: { cpu: "500m", memory: "1Gi" }
    limits: { cpu: "2000m", memory: "4Gi" }
```

## Security & Privacy Implementation

### 1. Data Encryption
```python
# Encryption at Rest
class EncryptedField:
    def __init__(self, key: str):
        self.fernet = Fernet(key.encode())
    
    def encrypt(self, data: str) -> str:
        return self.fernet.encrypt(data.encode()).decode()
    
    def decrypt(self, encrypted_data: str) -> str:
        return self.fernet.decrypt(encrypted_data.encode()).decode()

# Usage in models
class Message(Base):
    id = Column(UUID, primary_key=True)
    content_encrypted = Column(Text)  # Always encrypted
    
    @property 
    def content(self):
        return encryption_service.decrypt(self.content_encrypted)
    
    @content.setter
    def content(self, value):
        self.content_encrypted = encryption_service.encrypt(value)
```

### 2. GDPR Compliance Implementation
```python
class GDPRService:
    def export_user_data(self, user_id: str) -> dict:
        """Complete user data export for GDPR Article 20"""
        return {
            "personal_data": self.get_user_profile(user_id),
            "chat_history": self.get_all_messages(user_id),
            "health_data": self.get_health_metrics(user_id),
            "analytics": self.get_usage_analytics(user_id),
            "audit_log": self.get_user_audit_log(user_id),
            "exported_at": datetime.utcnow().isoformat(),
            "format_version": "1.0"
        }
    
    def delete_user_data(self, user_id: str) -> bool:
        """Complete user data deletion for GDPR Article 17"""
        try:
            # 1. Mark user as deleted (soft delete initially)
            user = db.query(User).filter(User.id == user_id).first()
            user.deleted_at = datetime.utcnow()
            
            # 2. Anonymize chat history (keep for AI training)
            self.anonymize_chat_history(user_id)
            
            # 3. Delete personal identifiable information
            self.purge_pii(user_id)
            
            # 4. Remove from all caches
            self.clear_user_cache(user_id)
            
            # 5. Schedule hard deletion after grace period
            schedule_hard_deletion.delay(user_id, delay=7*24*3600)
            
            return True
        except Exception as e:
            logger.error(f"GDPR deletion failed for {user_id}: {e}")
            return False
```

### 3. Rate Limiting & DDoS Protection
```python
# Multi-layer rate limiting
RATE_LIMITS = {
    "global": "1000/hour",          # Per IP
    "auth_login": "5/10min",        # Per IP
    "chat_send": "20/hour",         # Per user
    "health_sync": "10/hour",       # Per user
    "escalation": "3/day",          # Per user
    "data_export": "1/week"         # Per user
}

class RateLimiter:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def is_allowed(self, key: str, limit: str) -> bool:
        rate, period = limit.split('/')
        window = self.parse_time_window(period)
        
        current = self.redis.get(f"rate:{key}") or 0
        if int(current) >= int(rate):
            return False
            
        # Sliding window implementation
        self.redis.incr(f"rate:{key}")
        self.redis.expire(f"rate:{key}", window)
        return True
```

## Monitoring & Observability

### 1. Application Metrics
```python
# Key metrics to track
METRICS = {
    "business_metrics": [
        "daily_active_users",
        "chat_sessions_per_day", 
        "escalations_per_day",
        "health_data_syncs",
        "user_retention_rate"
    ],
    
    "technical_metrics": [
        "api_response_time_p95",
        "llm_response_time_p95", 
        "database_query_time_p95",
        "error_rate_per_endpoint",
        "cache_hit_ratio"
    ],
    
    "cost_metrics": [
        "llm_api_cost_per_day",
        "infrastructure_cost_per_user",
        "database_storage_growth",
        "bandwidth_usage"
    ]
}

# Health checks
@app.get("/health")
def health_check():
    checks = {
        "database": check_database_connection(),
        "redis": check_redis_connection(),
        "vector_db": check_vector_db_connection(),
        "llm_api": check_openai_api(),
        "disk_space": check_disk_usage() < 85
    }
    
    status = "healthy" if all(checks.values()) else "degraded"
    return {"status": status, "checks": checks, "timestamp": datetime.utcnow()}
```

### 2. Alerting Strategy
```yaml
alerts:
  critical:
    - error_rate > 5%
    - api_response_time_p95 > 2000ms  
    - database_connection_failures > 3
    - escalation_response_sla_breach
    
  warning:
    - daily_llm_cost > $500
    - cache_hit_ratio < 70%
    - disk_usage > 80%
    - user_signup_drop > 20%
    
  notification_channels:
    - slack: "#alerts-critical"
    - pagerduty: "ai-coach-oncall" 
    - email: "dev-team@aiwellbeingcoach.com"
```

## Deployment Architecture

### 1. Container Strategy
```dockerfile
# Multi-stage build for Chat Service
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
USER node
CMD ["node", "src/server.js"]
```

### 2. Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chat-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: chat-service
  template:
    metadata:
      labels:
        app: chat-service
    spec:
      containers:
      - name: chat-service
        image: aiwellbeingcoach/chat-service:v1.0.0
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-secret  
              key: url
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi" 
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 10
```

### 3. CI/CD Pipeline
```yaml
# GitHub Actions workflow
name: Deploy Backend Services

on:
  push:
    branches: [main]
    paths: ['backend/**']

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          npm test
          npm run test:integration
          
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Security scan
        run: |
          npm audit --audit-level=high
          docker run --rm -v "$PWD:/app" securecodewarrior/docker-security-scanner
          
  deploy-staging:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to staging
        run: |
          kubectl apply -f k8s/staging/ --namespace=staging
          kubectl rollout status deployment/chat-service -n staging
          
  smoke-tests:
    needs: [deploy-staging]
    runs-on: ubuntu-latest
    steps:
      - name: Run smoke tests
        run: |
          curl -f https://staging-api.aiwellbeingcoach.com/health
          npm run test:smoke -- --endpoint=https://staging-api.aiwellbeingcoach.com
          
  deploy-production:
    needs: [smoke-tests]
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to production  
        run: |
          kubectl apply -f k8s/production/ --namespace=production
          kubectl rollout status deployment/chat-service -n production --timeout=600s
```

## Technical Recommendations

### 1. Technology Stack
```yaml
Backend Services:
  - Language: Node.js 18+ (Chat, Auth, User services)
  - Language: Python 3.11+ (RAG/AI services)  
  - Framework: Express.js, FastAPI
  - WebSocket: Socket.io
  - ORM: Prisma (Node.js), SQLAlchemy (Python)

Databases:
  - Primary: PostgreSQL 15+ (ACID compliance, GDPR features)
  - Time-series: InfluxDB 2.0 (health metrics)
  - Vector: Pinecone (managed) or Weaviate (self-hosted)
  - Cache: Redis 7.0 (clustering support)

Infrastructure:
  - Container: Docker + Kubernetes
  - Cloud: AWS (recommended) or Google Cloud
  - API Gateway: Kong or AWS API Gateway
  - Load Balancer: AWS ALB or NGINX
  - Monitoring: Prometheus + Grafana + Jaeger
```

### 2. Scaling Considerations
```python
# Service scaling priorities (based on load)
SCALING_PRIORITY = {
    1: "chat_service",      # High user interaction
    2: "rag_engine",        # CPU/memory intensive  
    3: "api_gateway",       # Request routing bottleneck
    4: "auth_service",      # Authentication load
    5: "user_service"       # Profile/settings updates
}

# Database sharding strategy (when needed)
SHARDING_STRATEGY = {
    "users": "hash(user_id) % num_shards",
    "messages": "hash(user_id) % num_shards",  # Co-locate with users
    "health_metrics": "time_range",            # Time-based partitioning
    "escalations": "single_shard"              # Low volume, admin access
}
```

### 3. Development Best Practices
```yaml
Code Quality:
  - ESLint + Prettier (Node.js)
  - Black + Flake8 (Python)
  - Pre-commit hooks
  - 80%+ test coverage requirement
  
Security:
  - Dependency vulnerability scanning (npm audit, safety)
  - SAST tools (SonarQube, CodeQL)
  - Container image scanning
  - Regular penetration testing
  
Documentation:
  - OpenAPI specifications
  - Architecture Decision Records (ADRs)
  - Runbooks for operations
  - API integration guides
```

This architecture provides a solid foundation for the AI Wellbeing Coach backend, balancing scalability, cost efficiency, and GDPR compliance while maintaining the flexibility to evolve with user needs and technological advances.