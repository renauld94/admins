import React from 'react'

interface SceneOverlayProps {
  text: string
  visible: boolean
}

export function SceneOverlay({ text, visible }: SceneOverlayProps) {
  if (!visible) return null

  return (
    <div className="scene-overlay">
      {text}
    </div>
  )
}
