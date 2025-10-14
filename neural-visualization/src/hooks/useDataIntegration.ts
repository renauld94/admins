import { useState, useEffect, useRef } from 'react'

interface DataIntegrationConfig {
  WEBSOCKET_URL: string
  PROXMOX_API_URL: string
  GEOSERVER_WMS_URL: string
  MOODLE_STATS_WS: string
  MOCK_DATA: boolean
}

export function useDataIntegration(config: DataIntegrationConfig) {
  const [isConnected, setIsConnected] = useState(false)
  const [proxmoxStatus, setProxmoxStatus] = useState('Disconnected')
  const [geoserverStatus, setGeoserverStatus] = useState('Disconnected')
  const [moodleStatus, setMoodleStatus] = useState('Disconnected')
  const [systemMetrics, setSystemMetrics] = useState({
    cpu: 0,
    memory: 0,
    disk: 0,
    network: 0
  })
  const [geoserverQueries, setGeoserverQueries] = useState<any[]>([])
  const [moodleEvents, setMoodleEvents] = useState<any[]>([])
  
  const wsRef = useRef<WebSocket | null>(null)
  const proxmoxIntervalRef = useRef<NodeJS.Timeout | null>(null)

  // Mock data for offline mode
  const mockData = {
    systemMetrics: {
      cpu: Math.random() * 100,
      memory: Math.random() * 100,
      disk: Math.random() * 100,
      network: Math.random() * 100
    },
    geoserverQueries: [
      { id: 1, type: 'WMS', timestamp: Date.now(), responseTime: Math.random() * 1000 },
      { id: 2, type: 'WFS', timestamp: Date.now(), responseTime: Math.random() * 500 },
      { id: 3, type: 'WCS', timestamp: Date.now(), responseTime: Math.random() * 2000 }
    ],
    moodleEvents: [
      { id: 1, type: 'login', user: 'student1', timestamp: Date.now() },
      { id: 2, type: 'course_access', course: 'Python Academy', timestamp: Date.now() },
      { id: 3, type: 'quiz_complete', score: 85, timestamp: Date.now() }
    ]
  }

  // WebSocket connection
  useEffect(() => {
    if (config.MOCK_DATA) {
      setIsConnected(true)
      setProxmoxStatus('Mock Mode')
      setGeoserverStatus('Mock Mode')
      setMoodleStatus('Mock Mode')
      setSystemMetrics(mockData.systemMetrics)
      setGeoserverQueries(mockData.geoserverQueries)
      setMoodleEvents(mockData.moodleEvents)
      return
    }

    const connectWebSocket = () => {
      try {
        wsRef.current = new WebSocket(config.WEBSOCKET_URL)
        
        wsRef.current.onopen = () => {
          setIsConnected(true)
          console.log('WebSocket connected')
        }
        
        wsRef.current.onmessage = (event) => {
          try {
            const data = JSON.parse(event.data)
            
            switch (data.type) {
              case 'system_metrics':
                setSystemMetrics(data.payload)
                break
              case 'geoserver_query':
                setGeoserverQueries(prev => [...prev.slice(-99), data.payload])
                break
              case 'moodle_event':
                setMoodleEvents(prev => [...prev.slice(-99), data.payload])
                break
            }
          } catch (error) {
            console.error('Error parsing WebSocket message:', error)
          }
        }
        
        wsRef.current.onclose = () => {
          setIsConnected(false)
          console.log('WebSocket disconnected')
          // Reconnect after 5 seconds
          setTimeout(connectWebSocket, 5000)
        }
        
        wsRef.current.onerror = (error) => {
          console.error('WebSocket error:', error)
          setIsConnected(false)
        }
      } catch (error) {
        console.error('Error connecting WebSocket:', error)
        setIsConnected(false)
      }
    }

    connectWebSocket()

    return () => {
      if (wsRef.current) {
        wsRef.current.close()
      }
    }
  }, [config])

  // Proxmox API polling
  useEffect(() => {
    if (config.MOCK_DATA) return

    const pollProxmox = async () => {
      try {
        const response = await fetch(`${config.PROXMOX_API_URL}/api2/json/nodes`, {
          headers: {
            'Authorization': `PVEAPIToken=${process.env.PROXMOX_TOKEN}`,
            'Content-Type': 'application/json'
          }
        })
        
        if (response.ok) {
          setProxmoxStatus('Connected')
          const data = await response.json()
          // Process Proxmox data here
        } else {
          setProxmoxStatus('Error')
        }
      } catch (error) {
        console.error('Proxmox API error:', error)
        setProxmoxStatus('Disconnected')
      }
    }

    // Poll every 2 seconds
    proxmoxIntervalRef.current = setInterval(pollProxmox, 2000)
    pollProxmox() // Initial call

    return () => {
      if (proxmoxIntervalRef.current) {
        clearInterval(proxmoxIntervalRef.current)
      }
    }
  }, [config])

  // GeoServer status check
  useEffect(() => {
    if (config.MOCK_DATA) return

    const checkGeoServer = async () => {
      try {
        const response = await fetch(`${config.GEOSERVER_WMS_URL}/wms?service=WMS&request=GetCapabilities`)
        if (response.ok) {
          setGeoserverStatus('Connected')
        } else {
          setGeoserverStatus('Error')
        }
      } catch (error) {
        console.error('GeoServer check error:', error)
        setGeoserverStatus('Disconnected')
      }
    }

    checkGeoServer()
    const interval = setInterval(checkGeoServer, 10000) // Check every 10 seconds

    return () => clearInterval(interval)
  }, [config])

  // Moodle status check
  useEffect(() => {
    if (config.MOCK_DATA) return

    const checkMoodle = async () => {
      try {
        const response = await fetch(`${config.MOODLE_STATS_WS.replace('ws://', 'http://')}/status`)
        if (response.ok) {
          setMoodleStatus('Connected')
        } else {
          setMoodleStatus('Error')
        }
      } catch (error) {
        console.error('Moodle check error:', error)
        setMoodleStatus('Disconnected')
      }
    }

    checkMoodle()
    const interval = setInterval(checkMoodle, 15000) // Check every 15 seconds

    return () => clearInterval(interval)
  }, [config])

  // Update function for animation loop
  const update = (time: number) => {
    if (config.MOCK_DATA) {
      // Simulate data updates in mock mode
      setSystemMetrics({
        cpu: 50 + Math.sin(time * 0.1) * 20,
        memory: 60 + Math.cos(time * 0.15) * 15,
        disk: 40 + Math.sin(time * 0.05) * 10,
        network: 30 + Math.cos(time * 0.2) * 25
      })
    }
  }

  return {
    isConnected,
    proxmoxStatus,
    geoserverStatus,
    moodleStatus,
    systemMetrics,
    geoserverQueries,
    moodleEvents,
    update
  }
}
