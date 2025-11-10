#!/usr/bin/env python3
"""
D3.js Interactive Module Importance Display
Generates visualization showing clinical relevance and learning outcomes
Integrates with Moodle dashboard to display module importance
"""

import json
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any


class D3ModuleVisualizer:
    """Generate D3.js interactive displays for module importance"""
    
    def __init__(self):
        self.output_dir = Path("/home/simon/Learning-Management-System-Academy/staging/d3_visualizations")
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Vietnamese course modules with clinical relevance
        self.modules = [
            {
                "id": 101,
                "title": "Foundations of Vietnamese",
                "level": "Beginner",
                "clinical_relevance": 85,
                "learning_outcomes": ["Pronunciation", "Basic vocabulary", "Cultural context"],
                "completion_rate": 92,
                "avg_time_minutes": 45,
                "icon": "foundation",
                "color": "#E8423C"
            },
            {
                "id": 102,
                "title": "Interactive Communication",
                "level": "Intermediate",
                "clinical_relevance": 90,
                "learning_outcomes": ["Conversational skills", "Medical terminology", "Active listening"],
                "completion_rate": 88,
                "avg_time_minutes": 60,
                "icon": "communication",
                "color": "#C4A73C"
            },
            {
                "id": 103,
                "title": "Professional Expression",
                "level": "Advanced",
                "clinical_relevance": 95,
                "learning_outcomes": ["Professional tone", "Presentation skills", "Documentation"],
                "completion_rate": 84,
                "avg_time_minutes": 75,
                "icon": "professional",
                "color": "#1A3A52"
            },
            {
                "id": 104,
                "title": "Navigation & Culture",
                "level": "Intermediate",
                "clinical_relevance": 70,
                "learning_outcomes": ["Cultural competence", "Regional variations", "Business etiquette"],
                "completion_rate": 86,
                "avg_time_minutes": 50,
                "icon": "navigation",
                "color": "#7BA68F"
            },
            {
                "id": 105,
                "title": "Professional Development",
                "level": "Advanced",
                "clinical_relevance": 92,
                "learning_outcomes": ["Career progression", "Industry trends", "Networking"],
                "completion_rate": 81,
                "avg_time_minutes": 90,
                "icon": "professional",
                "color": "#E8423C"
            },
            {
                "id": 106,
                "title": "Mastery & Specialization",
                "level": "Expert",
                "clinical_relevance": 98,
                "learning_outcomes": ["Specialized vocabulary", "Research participation", "Thought leadership"],
                "completion_rate": 76,
                "avg_time_minutes": 120,
                "icon": "mastery",
                "color": "#C4A73C"
            }
        ]
    
    def generate_sunburst_chart(self) -> str:
        """Generate D3.js sunburst chart showing module hierarchy and importance"""
        
        # Build hierarchical data structure
        root_data = {
            "name": "Vietnamese Course",
            "value": 100,
            "importance": 90,
            "children": []
        }
        
        # Group modules by level
        levels = {
            "Beginner": {"name": "Beginner Path", "children": []},
            "Intermediate": {"name": "Intermediate Path", "children": []},
            "Advanced": {"name": "Advanced Path", "children": []},
            "Expert": {"name": "Expert Path", "children": []}
        }
        
        for module in self.modules:
            level_key = module["level"]
            levels[level_key]["children"].append({
                "name": module["title"],
                "value": module["clinical_relevance"],
                "importance": module["clinical_relevance"],
                "completion": module["completion_rate"],
                "time_minutes": module["avg_time_minutes"],
                "color": module["color"],
                "outcomes": len(module["learning_outcomes"])
            })
        
        root_data["children"] = list(levels.values())
        
        html_template = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vietnamese Course Module Importance</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }}
        
        .container {{
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
        }}
        
        h1 {{
            text-align: center;
            color: #1A3A52;
            margin-bottom: 10px;
            font-size: 28px;
        }}
        
        .subtitle {{
            text-align: center;
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }}
        
        .chart-container {{
            display: flex;
            justify-content: center;
            position: relative;
            height: 700px;
        }}
        
        svg {{
            overflow: visible;
        }}
        
        .node {{
            cursor: pointer;
            transition: all 0.3s ease;
        }}
        
        .node circle {{
            stroke: white;
            stroke-width: 2px;
        }}
        
        .node:hover circle {{
            stroke-width: 3px;
            filter: brightness(1.1);
        }}
        
        .node text {{
            font-size: 12px;
            text-anchor: middle;
            pointer-events: none;
            fill: white;
            font-weight: 500;
        }}
        
        .tooltip {{
            position: absolute;
            background: rgba(0,0,0,0.9);
            color: white;
            padding: 12px 16px;
            border-radius: 6px;
            font-size: 13px;
            pointer-events: none;
            z-index: 1000;
            display: none;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        }}
        
        .tooltip.active {{
            display: block;
        }}
        
        .tooltip-title {{
            font-weight: 600;
            margin-bottom: 6px;
        }}
        
        .tooltip-stat {{
            margin: 4px 0;
            font-size: 12px;
        }}
        
        .legend {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 30px;
            padding-top: 30px;
            border-top: 2px solid #eee;
        }}
        
        .legend-item {{
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 13px;
        }}
        
        .legend-color {{
            width: 20px;
            height: 20px;
            border-radius: 50%;
            border: 2px solid white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        
        .stats {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        
        .stat-card {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }}
        
        .stat-value {{
            font-size: 32px;
            font-weight: bold;
            margin-bottom: 5px;
        }}
        
        .stat-label {{
            font-size: 13px;
            opacity: 0.9;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🎓 Vietnamese Course Module Importance</h1>
        <p class="subtitle">Interactive visualization showing clinical relevance and learning outcomes</p>
        
        <div class="stats">
            <div class="stat-card">
                <div class="stat-value">6</div>
                <div class="stat-label">Strategic Modules</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">91%</div>
                <div class="stat-label">Avg Clinical Relevance</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">85%</div>
                <div class="stat-label">Avg Completion Rate</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">74 min</div>
                <div class="stat-label">Avg Study Time</div>
            </div>
        </div>
        
        <div class="chart-container">
            <svg id="sunburst"></svg>
            <div class="tooltip"></div>
        </div>
        
        <div class="legend">
            <div class="legend-item">
                <div class="legend-color" style="background: #E8423C;"></div>
                <span><strong>Clinical Focus</strong> - High clinical relevance (85%+)</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #C4A73C;"></div>
                <span><strong>Professional</strong> - Career development (90%+)</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #1A3A52;"></div>
                <span><strong>Expertise</strong> - Advanced skills (95%+)</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #7BA68F;"></div>
                <span><strong>Cultural</strong> - Competency & context (70%+)</span>
            </div>
        </div>
    </div>
    
    <script>
        // Data
        const data = {json.dumps(root_data)};
        
        // Dimensions
        const width = 650;
        const height = 650;
        const radius = width / 2;
        
        // Create SVG
        const svg = d3.select("#sunburst")
            .attr("width", width)
            .attr("height", height)
            .append("g")
            .attr("transform", `translate(${{width / 2}},${{height / 2}})`);
        
        // Create hierarchy
        const hierarchy = d3.hierarchy(data)
            .sum(d => d.value)
            .sort((a, b) => b.value - a.value);
        
        // Create partition layout
        const partition = d3.partition()
            .size([2 * Math.PI, radius]);
        
        const root = partition(hierarchy);
        
        // Color scale
        const color = d3.scaleOrdinal()
            .domain(["Beginner Path", "Intermediate Path", "Advanced Path", "Expert Path"])
            .range(["#E8423C", "#C4A73C", "#1A3A52", "#7BA68F"]);
        
        // Create arcs
        const arc = d3.arc()
            .startAngle(d => d.x0)
            .endAngle(d => d.x1)
            .innerRadius(d => d.y0)
            .outerRadius(d => d.y1);
        
        // Tooltip
        const tooltip = d3.select(".tooltip");
        
        // Draw paths
        svg.selectAll("g")
            .data(root.descendants())
            .join("g")
            .attr("class", "node")
            .append("path")
            .attr("d", arc)
            .attr("fill", d => {{
                if (d.depth === 0) return "#fff";
                if (d.depth === 1) return color(d.data.name);
                return d3.rgb(color(d.parent.data.name)).brighter(0.5);
            }})
            .attr("stroke", "white")
            .attr("stroke-width", 2)
            .on("mouseover", function(event, d) {{
                if (d.depth === 0) return;
                
                d3.select(this).transition().duration(200)
                    .attr("stroke-width", 3);
                
                let content = `<div class="tooltip-title">${{d.data.name}}</div>`;
                if (d.data.importance) {{
                    content += `<div class="tooltip-stat">Clinical Relevance: ${{d.data.importance}}%</div>`;
                }}
                if (d.data.completion) {{
                    content += `<div class="tooltip-stat">Completion Rate: ${{d.data.completion}}%</div>`;
                }}
                if (d.data.time_minutes) {{
                    content += `<div class="tooltip-stat">Avg Time: ${{d.data.time_minutes}} min</div>`;
                }}
                if (d.data.outcomes) {{
                    content += `<div class="tooltip-stat">Learning Outcomes: ${{d.data.outcomes}}</div>`;
                }}
                
                tooltip.html(content)
                    .style("left", (event.pageX + 10) + "px")
                    .style("top", (event.pageY - 28) + "px")
                    .classed("active", true);
            }})
            .on("mouseout", function() {{
                d3.select(this).transition().duration(200)
                    .attr("stroke-width", 2);
                tooltip.classed("active", false);
            }});
        
        // Add labels
        svg.selectAll(".node")
            .append("text")
            .attr("transform", d => {{
                const angle = (d.x0 + d.x1) / 2 - Math.PI / 2;
                const radius = (d.y0 + d.y1) / 2;
                return `rotate(${{angle * 180 / Math.PI}}) translate(${{radius}},0)`;
            }})
            .attr("text-anchor", d => (d.x0 + d.x1) / 2 > Math.PI ? "end" : "start")
            .attr("transform", d => {{
                const angle = (d.x0 + d.x1) / 2 - Math.PI / 2;
                const radius = (d.y0 + d.y1) / 2;
                const rotation = angle * 180 / Math.PI;
                const x = radius;
                const y = (d.x0 + d.x1) / 2 > Math.PI ? -8 : 8;
                return `rotate(${{rotation}}) translate(${{x}},${{y}})`;
            }})
            .text(d => {{
                if (d.depth <= 1) return d.data.name;
                return d.data.name.split(" ").slice(0, 2).join(" ");
            }})
            .style("font-size", d => Math.max(10, (d.y1 - d.y0) * 0.8) + "px");
    </script>
</body>
</html>"""
        
        output_file = self.output_dir / "module_importance_sunburst.html"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(html_template)
        
        return str(output_file)
    
    def generate_clinical_relevance_bubble(self) -> str:
        """Generate bubble chart showing clinical relevance vs completion rate"""
        
        bubble_data = [
            {
                "module": m["title"],
                "relevance": m["clinical_relevance"],
                "completion": m["completion_rate"],
                "time": m["avg_time_minutes"],
                "color": m["color"]
            }
            for m in self.modules
        ]
        
        html_template = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clinical Relevance vs Completion Analysis</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <style>
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
            margin: 0;
        }}
        
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
        }}
        
        h1 {{
            text-align: center;
            color: #1A3A52;
            margin-bottom: 10px;
            font-size: 28px;
        }}
        
        .subtitle {{
            text-align: center;
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }}
        
        .chart-wrapper {{
            display: flex;
            justify-content: center;
            position: relative;
        }}
        
        .bubble {{
            cursor: pointer;
            transition: all 0.2s ease;
            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.1));
        }}
        
        .bubble:hover {{
            filter: drop-shadow(0 6px 12px rgba(0,0,0,0.2));
            opacity: 0.9;
        }}
        
        .bubble-label {{
            font-size: 12px;
            font-weight: 600;
            text-anchor: middle;
            fill: white;
            pointer-events: none;
        }}
        
        .axis-label {{
            font-size: 14px;
            font-weight: 600;
        }}
        
        .tooltip {{
            position: absolute;
            background: rgba(0,0,0,0.9);
            color: white;
            padding: 12px 16px;
            border-radius: 6px;
            font-size: 12px;
            pointer-events: none;
            display: none;
            z-index: 1000;
        }}
        
        .tooltip.show {{
            display: block;
        }}
        
        .insights {{
            margin-top: 30px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }}
        
        .insight {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
        }}
        
        .insight-title {{
            font-weight: 600;
            margin-bottom: 8px;
        }}
        
        .insight-text {{
            font-size: 13px;
            line-height: 1.5;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Clinical Relevance vs Completion Analysis</h1>
        <p class="subtitle">Bubble size represents study time; bubble position shows relevance vs completion rate</p>
        
        <div class="chart-wrapper">
            <svg id="bubble-chart" width="900" height="600"></svg>
            <div class="tooltip"></div>
        </div>
        
        <div class="insights">
            <div class="insight">
                <div class="insight-title">🎯 High Priority</div>
                <div class="insight-text">Mastery & Professional modules have 92-98% clinical relevance but require 90-120 min study time</div>
            </div>
            <div class="insight">
                <div class="insight-title">📈 Completion Leaders</div>
                <div class="insight-text">Foundations module leads with 92% completion, providing strong foundation for advanced topics</div>
            </div>
            <div class="insight">
                <div class="insight-title">⚖️ Balanced Path</div>
                <div class="insight-text">Intermediate modules offer good balance of clinical relevance (80-90%) with reasonable completion (84-88%)</div>
            </div>
            <div class="insight">
                <div class="insight-title">🚀 Growth Opportunity</div>
                <div class="insight-text">Expert modules (98% relevance) could improve completion (76%) with enhanced engagement strategies</div>
            </div>
        </div>
    </div>
    
    <script>
        const data = {json.dumps(bubble_data)};
        
        // Dimensions
        const margin = {{top: 20, right: 20, bottom: 60, left: 60}};
        const width = 900 - margin.left - margin.right;
        const height = 600 - margin.top - margin.bottom;
        
        // Scales
        const xScale = d3.scaleLinear()
            .domain([65, 100])
            .range([0, width]);
        
        const yScale = d3.scaleLinear()
            .domain([70, 95])
            .range([height, 0]);
        
        const radiusScale = d3.scaleSqrt()
            .domain([0, 120])
            .range([20, 60]);
        
        // Create SVG
        const svg = d3.select("#bubble-chart")
            .append("g")
            .attr("transform", `translate(${{margin.left}},${{margin.top}})`);
        
        // Add axes
        svg.append("g")
            .attr("transform", `translate(0,${{height}})`)
            .call(d3.axisBottom(xScale))
            .append("text")
            .attr("x", width / 2)
            .attr("y", 40)
            .attr("text-anchor", "middle")
            .attr("fill", "black")
            .attr("class", "axis-label")
            .text("Clinical Relevance (%)");
        
        svg.append("g")
            .call(d3.axisLeft(yScale))
            .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 0 - margin.left)
            .attr("x", 0 - (height / 2))
            .attr("dy", "1em")
            .attr("text-anchor", "middle")
            .attr("fill", "black")
            .attr("class", "axis-label")
            .text("Completion Rate (%)");
        
        // Tooltip
        const tooltip = d3.select(".tooltip");
        
        // Draw bubbles
        svg.selectAll(".bubble")
            .data(data)
            .enter()
            .append("circle")
            .attr("class", "bubble")
            .attr("cx", d => xScale(d.relevance))
            .attr("cy", d => yScale(d.completion))
            .attr("r", d => radiusScale(d.time))
            .attr("fill", d => d.color)
            .attr("opacity", 0.8)
            .on("mouseover", function(event, d) {{
                tooltip.html(`
                    <strong>${{d.module}}</strong><br/>
                    Relevance: ${{d.relevance}}%<br/>
                    Completion: ${{d.completion}}%<br/>
                    Avg Time: ${{d.time}} min
                `)
                    .style("left", (event.pageX + 10) + "px")
                    .style("top", (event.pageY - 28) + "px")
                    .classed("show", true);
                
                d3.select(this).transition()
                    .attr("opacity", 1)
                    .attr("r", d => radiusScale(d.time) * 1.2);
            }})
            .on("mouseout", function(event, d) {{
                tooltip.classed("show", false);
                d3.select(this).transition()
                    .attr("opacity", 0.8)
                    .attr("r", d => radiusScale(d.time));
            }});
        
        // Add labels
        svg.selectAll(".label")
            .data(data)
            .enter()
            .append("text")
            .attr("class", "bubble-label")
            .attr("x", d => xScale(d.relevance))
            .attr("y", d => yScale(d.completion) + 4)
            .text(d => d.module.split(" ").slice(0, 2).join(" "));
    </script>
</body>
</html>"""
        
        output_file = self.output_dir / "clinical_relevance_bubble.html"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(html_template)
        
        return str(output_file)
    
    def generate_learning_outcome_heatmap(self) -> str:
        """Generate heatmap showing learning outcomes across modules"""
        
        outcomes_data = []
        all_outcomes = set()
        
        for module in self.modules:
            for outcome in module["learning_outcomes"]:
                all_outcomes.add(outcome)
                outcomes_data.append({
                    "module": module["title"],
                    "outcome": outcome,
                    "importance": module["clinical_relevance"]
                })
        
        html_template = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Learning Outcomes Heatmap</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <style>
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
            margin: 0;
        }}
        
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
        }}
        
        h1 {{
            text-align: center;
            color: #1A3A52;
            margin-bottom: 10px;
            font-size: 28px;
        }}
        
        .subtitle {{
            text-align: center;
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }}
        
        .heatmap-container {{
            overflow-x: auto;
        }}
        
        .cell {{
            cursor: pointer;
            transition: all 0.2s ease;
        }}
        
        .cell:hover {{
            stroke: #333;
            stroke-width: 2;
        }}
        
        .cell-text {{
            font-size: 11px;
            text-anchor: middle;
            pointer-events: none;
            font-weight: 500;
        }}
        
        .heatmap-title {{
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 20px;
        }}
        
        .axis-label {{
            font-size: 12px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🔥 Learning Outcomes Heatmap</h1>
        <p class="subtitle">Color intensity indicates importance of learning outcome within each module</p>
        
        <div class="heatmap-container">
            <svg id="heatmap"></svg>
        </div>
    </div>
    
    <script>
        const rawData = {json.dumps(outcomes_data)};
        const modules = [...new Set(rawData.map(d => d.module))];
        const outcomes = [...new Set(rawData.map(d => d.outcome))];
        
        // Build matrix
        const matrix = {{}};
        modules.forEach(m => {{
            matrix[m] = {{}};
            outcomes.forEach(o => {{
                matrix[m][o] = 0;
            }});
        }});
        
        rawData.forEach(d => {{
            matrix[d.module][d.outcome] = d.importance;
        }});
        
        // Dimensions
        const margin = {{top: 20, right: 20, bottom: 200, left: 300}};
        const cellSize = 40;
        const width = outcomes.length * cellSize + margin.left + margin.right;
        const height = modules.length * cellSize + margin.top + margin.bottom;
        
        const svg = d3.select("#heatmap")
            .attr("width", width)
            .attr("height", height)
            .append("g")
            .attr("transform", `translate(${{margin.left}},${{margin.top}})`);
        
        // Color scale
        const colorScale = d3.scaleLinear()
            .domain([0, 50, 100])
            .range(["#f0f0f0", "#C4A73C", "#E8423C"]);
        
        // X axis (outcomes)
        svg.selectAll(".x-label")
            .data(outcomes)
            .enter()
            .append("text")
            .attr("class", "x-label axis-label")
            .attr("x", (d, i) => i * cellSize + cellSize / 2)
            .attr("y", -10)
            .attr("text-anchor", "start")
            .attr("transform", (d, i) => `rotate(-45 ${{i * cellSize + cellSize / 2}} -10)`)
            .text(d => d);
        
        // Y axis (modules)
        svg.selectAll(".y-label")
            .data(modules)
            .enter()
            .append("text")
            .attr("class", "y-label axis-label")
            .attr("x", -10)
            .attr("y", (d, i) => i * cellSize + cellSize / 2 + 5)
            .attr("text-anchor", "end")
            .text(d => d.substring(0, 20));
        
        // Cells
        svg.selectAll(".cell")
            .data(rawData)
            .enter()
            .append("rect")
            .attr("class", "cell")
            .attr("x", d => outcomes.indexOf(d.outcome) * cellSize)
            .attr("y", d => modules.indexOf(d.module) * cellSize)
            .attr("width", cellSize)
            .attr("height", cellSize)
            .attr("fill", d => colorScale(d.importance))
            .attr("stroke", "#ccc")
            .attr("stroke-width", 1);
        
        // Cell values
        svg.selectAll(".cell-value")
            .data(rawData)
            .enter()
            .append("text")
            .attr("class", "cell-text")
            .attr("x", d => outcomes.indexOf(d.outcome) * cellSize + cellSize / 2)
            .attr("y", d => modules.indexOf(d.module) * cellSize + cellSize / 2 + 5)
            .text(d => d.importance + "%")
            .attr("fill", d => d.importance > 75 ? "white" : "black");
    </script>
</body>
</html>"""
        
        output_file = self.output_dir / "learning_outcomes_heatmap.html"
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(html_template)
        
        return str(output_file)
    
    def generate_all_visualizations(self) -> Dict[str, str]:
        """Generate all D3.js visualizations"""
        
        print("\n" + "="*80)
        print("🎨 D3.js Interactive Module Visualizations")
        print("="*80)
        
        results = {}
        
        print("\n[1/3] Generating sunburst chart...")
        results["sunburst"] = self.generate_sunburst_chart()
        print(f"✅ Sunburst: {results['sunburst']}")
        
        print("\n[2/3] Generating clinical relevance bubble chart...")
        results["bubble"] = self.generate_clinical_relevance_bubble()
        print(f"✅ Bubble: {results['bubble']}")
        
        print("\n[3/3] Generating learning outcomes heatmap...")
        results["heatmap"] = self.generate_learning_outcome_heatmap()
        print(f"✅ Heatmap: {results['heatmap']}")
        
        # Generate manifest
        manifest = {
            "generated_at": datetime.now().isoformat(),
            "visualizations": results,
            "total_modules": len(self.modules),
            "integration_path": "/staging/d3_visualizations/",
            "moodle_integration": {
                "destination": "/var/www/moodle/course/view.php?id=10",
                "embed_code": '<iframe src="/course/d3_visualizations/module_importance_sunburst.html" width="100%" height="700" frameborder="0"></iframe>'
            }
        }
        
        manifest_file = self.output_dir / "D3_VISUALIZATIONS_MANIFEST.json"
        with open(manifest_file, 'w') as f:
            json.dump(manifest, f, indent=2)
        
        print(f"\n✅ Manifest: {manifest_file}")
        print("\n" + "="*80)
        print("✨ All D3.js visualizations generated successfully!")
        print("="*80 + "\n")
        
        return results


def main():
    visualizer = D3ModuleVisualizer()
    visualizations = visualizer.generate_all_visualizations()
    
    print("\n📊 D3.js Visualizations Ready:")
    for name, path in visualizations.items():
        print(f"  • {name}: {path}")


if __name__ == "__main__":
    main()
