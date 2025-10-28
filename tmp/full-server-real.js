const express = require('express')
const app = express()
const port = process.env.PORT || 3001

async function startPackageServer(){
  try {
    const { ServerCore } = require('@modelcontextprotocol/server-core')
    const fsProvider = require('@modelcontextprotocol/server-filesystem')
    console.log('Found @modelcontextprotocol packages; starting ServerCore')
    const core = new ServerCore({ port })
    core.registerProvider('filesystem', fsProvider)
    await core.start()
    console.log('Full MCP package-based server started on', port)
    return true
  } catch (err) {
    console.log('Package-based MCP server failed to start (packages missing or error):', err.message)
    return false
  }
}

async function startShimServer(){
  app.get('/health', (req, res) => res.json({ ok: true, server: 'full-mcp-shim' }))
  app.get('/providers', (req, res) => res.json({ providers: ['filesystem', 'shell'] }))
  // simple filesystem listing endpoint for testing
  const fs = require('fs')
  const path = require('path')
  app.get('/fs/list', (req, res) => {
    const p = req.query.path || '.'
    fs.readdir(p, { withFileTypes: true }, (err, entries) => {
      if (err) return res.status(500).json({ error: err.message })
      res.json(entries.map(e => ({ name: e.name, isDir: e.isDirectory() })))
    })
  })

  app.get('/', (req, res) => res.send('Full MCP shim running on ' + port))

  app.listen(port, () => console.log('Full MCP shim listening', port))
}

;(async () => {
  const ok = await startPackageServer()
  if (!ok) {
    startShimServer()
  }
})().catch(err => { console.error(err); process.exit(1) })
