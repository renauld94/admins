import React from 'react'

export function LoadingScreen() {
  return (
    <div className="loading-overlay">
      <div className="loading-spinner"></div>
      <div>
        <div>Initializing Data Intelligence Platform...</div>
        <div style={{ fontSize: '14px', opacity: 0.7, marginTop: '10px' }}>
          From neural networks to global data networks
        </div>
      </div>
    </div>
  )
}
