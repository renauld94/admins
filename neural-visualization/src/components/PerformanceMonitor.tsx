import React, { useState, useEffect } from 'react'

export function PerformanceMonitor() {
  const [fps, setFps] = useState(60)
  const [drawCalls, setDrawCalls] = useState(0)
  const [triangles, setTriangles] = useState(0)
  const [memory, setMemory] = useState(0)

  useEffect(() => {
    let animationId: number
    let lastTime = performance.now()
    let frameCount = 0

    const updateMetrics = () => {
      const currentTime = performance.now()
      frameCount++
      
      if (currentTime - lastTime >= 1000) {
        setFps(Math.round((frameCount * 1000) / (currentTime - lastTime)))
        frameCount = 0
        lastTime = currentTime
        
        // Simulate other metrics (in a real app, these would come from WebGL context)
        setDrawCalls(Math.floor(Math.random() * 100) + 50)
        setTriangles(Math.floor(Math.random() * 10000) + 5000)
        setMemory(Math.floor(Math.random() * 100) + 200)
      }
      
      animationId = requestAnimationFrame(updateMetrics)
    }

    updateMetrics()

    return () => {
      if (animationId) {
        cancelAnimationFrame(animationId)
      }
    }
  }, [])

  return (
    <div className="performance-info">
      <div>FPS: {fps}</div>
      <div>Draw Calls: {drawCalls}</div>
      <div>Triangles: {triangles.toLocaleString()}</div>
      <div>Memory: {memory}MB</div>
    </div>
  )
}
