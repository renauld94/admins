const express = require('express')
const app = express()
const port = process.env.PORT || 3001
app.get('/health', (req,res)=>res.json({ok:true,server:'full-mcp-scaffold'}))
app.get('/', (req,res)=>res.send('Full MCP scaffold running on '+port))
app.listen(port, ()=>console.log('Full MCP scaffold listening',port))
