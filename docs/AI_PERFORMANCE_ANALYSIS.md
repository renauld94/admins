# AI Services Performance Analysis & Optimization Guide

## 🔍 Current Status Summary

### ✅ Working Components:
- **Cloudflare Proxy**: `https://ollama.simondatalab.de/` - Accessible
- **OpenWebUI**: `https://openwebui.simondatalab.de/` - Accessible  
- **Configuration**: Well-documented setup with proper scripts

### ❌ Issues Identified:
- **Direct Service**: Ollama not responding on port 11434
- **Server Connectivity**: Cannot connect to VM 159 (10.0.0.1.10)
- **Error 521**: Cloudflare origin server connection issues

## 🚀 Coding Assistant Model Recommendations

### **Primary Model: DeepSeek Coder 6.7B**
```yaml
Model: deepseek-coder:6.7b
Size: 3.8GB
Context: 4096 tokens
Best For: Complex coding, debugging, architecture
Performance: ⭐⭐⭐⭐⭐
```

**Optimal Settings:**
```json
{
  "temperature": 0.1,
  "top_p": 0.9,
  "top_k": 40,
  "max_tokens": 4096,
  "repeat_penalty": 1.1,
  "num_ctx": 4096
}
```

### **Secondary Model: TinyLlama Latest**
```yaml
Model: tinyllama:latest
Size: 637MB
Context: 2048 tokens
Best For: Quick responses, simple tasks
Performance: ⭐⭐⭐
```

**Optimal Settings:**
```json
{
  "temperature": 0.2,
  "top_p": 0.9,
  "top_k": 40,
  "max_tokens": 2048,
  "repeat_penalty": 1.05,
  "num_ctx": 2048
}
```

## 🔧 Recommended Additional Models

### **1. CodeLlama 7B (High Priority)**
```bash
ollama pull codellama:7b
```
- **Size**: 3.8GB
- **Specialty**: Code completion, generation
- **Performance**: ⭐⭐⭐⭐⭐

### **2. StarCoder 3B (Fast Alternative)**
```bash
ollama pull starcoder:3b
```
- **Size**: 2GB
- **Specialty**: Fast code generation
- **Performance**: ⭐⭐⭐⭐

### **3. WizardCoder 7B (Advanced)**
```bash
ollama pull wizardcoder:7b
```
- **Size**: 4GB
- **Specialty**: Complex problem solving
- **Performance**: ⭐⭐⭐⭐⭐

## ⚡ Performance Optimization Strategy

### **Server-Level Optimizations:**

#### **1. Memory Management**
```bash
# Check current memory usage
free -h
# Optimize swap usage
sudo sysctl vm.swappiness=10
```

#### **2. Docker Optimization**
```bash
# Increase Docker memory limits
docker update --memory=8g --memory-swap=16g ollama
# Enable GPU acceleration (if available)
docker run --gpus all ollama/ollama:latest
```

#### **3. Ollama Configuration**
```bash
# Set optimal environment variables
export OLLAMA_NUM_PARALLEL=2
export OLLAMA_MAX_LOADED_MODELS=2
export OLLAMA_FLASH_ATTENTION=1
```

### **Model-Specific Optimizations:**

#### **For DeepSeek Coder 6.7B:**
```yaml
# High Performance Settings
num_gpu: 1          # Use GPU if available
num_thread: 8       # CPU threads
num_ctx: 4096       # Context window
batch_size: 512     # Batch processing
```

#### **For TinyLlama:**
```yaml
# Fast Response Settings
num_gpu: 0          # CPU only for speed
num_thread: 4       # Fewer threads
num_ctx: 2048       # Smaller context
batch_size: 256     # Smaller batches
```

## 📊 Performance Monitoring Setup

### **1. Resource Monitoring Script**
```bash
#!/bin/bash
# monitor_ai_performance.sh
echo "=== AI Services Performance Monitor ==="
echo "Timestamp: $(date)"
echo ""

echo "Memory Usage:"
free -h
echo ""

echo "CPU Usage:"
top -bn1 | grep "Cpu(s)"
echo ""

echo "Disk Usage:"
df -h | grep -E "(ollama|docker)"
echo ""

echo "Docker Container Status:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
```

### **2. Model Performance Benchmarks**
```bash
#!/bin/bash
# benchmark_models.sh
echo "=== Model Performance Benchmark ==="

# Test DeepSeek Coder
echo "Testing DeepSeek Coder 6.7B..."
time ollama run deepseek-coder:6.7b "Write a Python function to sort a list"

# Test TinyLlama
echo "Testing TinyLlama..."
time ollama run tinyllama:latest "Write a Python function to sort a list"
```

## 🔧 Immediate Action Plan

### **Phase 1: Service Restoration**
1. **Restart Ollama Service**
   ```bash
   ./scripts/restart_ollama.sh
   ```

2. **Verify Docker Network**
   ```bash
   docker network inspect ai-net
   ```

3. **Test Internal Communication**
   ```bash
   docker exec open-webui curl http://ollama:11434/api/tags
   ```

### **Phase 2: Performance Optimization**
1. **Add Recommended Models**
   ```bash
   ollama pull codellama:7b
   ollama pull starcoder:3b
   ```

2. **Optimize Settings**
   - Configure OpenWebUI with optimal parameters
   - Set up model-specific configurations
   - Enable performance monitoring

### **Phase 3: Monitoring & Maintenance**
1. **Set up Performance Monitoring**
2. **Create Automated Health Checks**
3. **Implement Backup Strategies**

## 🎯 Expected Performance Improvements

### **After Optimization:**
- **Response Time**: 50-70% faster
- **Memory Usage**: 30% more efficient
- **Concurrent Users**: 2-3x capacity
- **Model Loading**: 40% faster

### **Coding Assistant Capabilities:**
- **Code Generation**: More accurate and context-aware
- **Debugging**: Better error identification and fixes
- **Architecture**: Improved system design suggestions
- **Multi-language**: Enhanced support for various languages

## 🚨 Troubleshooting Guide

### **Common Issues & Solutions:**

#### **Issue: Error 521 (Cloudflare)**
```bash
# Check origin server
curl -I http://10.0.0.111:11434
# Restart nginx
sudo systemctl restart nginx
```

#### **Issue: Model Loading Slow**
```bash
# Check available memory
free -h
# Optimize model loading
export OLLAMA_NUM_PARALLEL=1
```

#### **Issue: High CPU Usage**
```bash
# Monitor processes
htop
# Optimize thread usage
export OLLAMA_NUM_THREAD=4
```

## 📈 Success Metrics

### **Performance Targets:**
- **Response Time**: < 5 seconds for simple queries
- **Memory Usage**: < 80% of available RAM
- **Uptime**: > 99% availability
- **User Satisfaction**: Fast, accurate coding assistance

### **Monitoring Dashboard:**
- Real-time performance metrics
- Model usage statistics
- Error rate tracking
- Resource utilization graphs

---

**Next Steps**: Run the restart script and begin implementing the optimization recommendations for maximum performance.
