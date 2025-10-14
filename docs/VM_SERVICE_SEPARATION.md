# VM Service Separation Summary

## 🎯 Service Distribution

### VM 106 (vm106-geoneural1000111) - 10.0.0.106
**Purpose**: Geospatial and Learning Platform Services
- ✅ **GeoServer**: Geospatial data services
- ✅ **MLflow**: ML experiment tracking
- ✅ **Learning Platform**: JupyterHub, Moodle
- ✅ **Database**: MariaDB for Moodle
- ✅ **Web Infrastructure**: Nginx proxy, SSL

### VM 159 (ubuntuai-1000110) - 10.0.0.110
**Purpose**: AI Services and Models
- ✅ **Ollama**: AI model server (Port 11434)
- ✅ **OpenWebUI**: AI web interface (Port 3001)
- ✅ **MLflow**: ML experiment tracking (Port 5000)

## 🔗 Access Information

### VM 106 Services
- **GeoServer**: http://10.0.0.106:8080
- **MLflow**: http://10.0.0.106:5000
- **Learning Platform**: http://10.0.0.106:80

### VM 159 AI Services
- **Ollama API**: http://10.0.0.110:11434
- **OpenWebUI**: http://10.0.0.110:3001
- **MLflow**: http://10.0.0.110:5000

## 🛠️ Management Commands

### VM 106 (Geospatial Services)
```bash
ssh geoserver-vm
ssh enterprise-vm106
```

### VM 159 (AI Services)
```bash
ssh ai-services-vm159
ssh ollama-vm159
ssh openwebui-vm159
```

## ✅ Separation Complete
- AI services removed from VM 106
- AI services confirmed running on VM 159
- SSH configurations updated
- Service separation documented
