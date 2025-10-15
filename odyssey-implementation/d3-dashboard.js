/**
 * D3.js Learning Dashboard
 * Interactive visualizations for the Learning Odyssey
 */

import * as d3 from 'd3';

class LearningDashboard {
    constructor(containerId) {
        this.container = d3.select(`#${containerId}`);
        this.data = {};
        this.visualizations = {};
        this.colors = {
            primary: '#00ff88',
            secondary: '#0066ff',
            accent: '#ff6600',
            success: '#00ff00',
            warning: '#ffaa00',
            danger: '#ff0000',
            background: '#0a0a0a',
            surface: '#1a1a1a'
        };
        
        this.init();
    }
    
    init() {
        this.setupContainer();
        this.createVisualizations();
        this.setupEventListeners();
    }
    
    setupContainer() {
        this.container
            .style('background', this.colors.background)
            .style('color', '#ffffff')
            .style('font-family', 'Arial, sans-serif');
    }
    
    createVisualizations() {
        this.createProgressRadar();
        this.createTimeHeatmap();
        this.createSkillEvolution();
        this.createCommunityNetwork();
        this.createEngagementGauge();
    }
    
    createProgressRadar() {
        const radarContainer = this.container
            .append('div')
            .attr('class', 'radar-container')
            .style('width', '300px')
            .style('height', '300px')
            .style('float', 'left')
            .style('margin', '10px');
        
        const radarTitle = radarContainer
            .append('h3')
            .text('Skill Mastery Radar')
            .style('text-align', 'center')
            .style('color', this.colors.primary);
        
        const radarSvg = radarContainer
            .append('svg')
            .attr('width', 280)
            .attr('height', 280)
            .style('margin', '10px');
        
        this.visualizations.radar = radarSvg;
        this.updateRadarChart();
    }
    
    updateRadarChart() {
        const svg = this.visualizations.radar;
        const width = 280;
        const height = 280;
        const centerX = width / 2;
        const centerY = height / 2;
        const radius = 100;
        
        // Clear previous content
        svg.selectAll('*').remove();
        
        // Sample data for skills
        const skills = [
            { name: 'Python', value: 0.8 },
            { name: 'PySpark', value: 0.6 },
            { name: 'Git', value: 0.7 },
            { name: 'Databricks', value: 0.3 },
            { name: 'Data Analysis', value: 0.9 },
            { name: 'Visualization', value: 0.5 }
        ];
        
        // Create scales
        const angleScale = d3.scaleLinear()
            .domain([0, skills.length])
            .range([0, 2 * Math.PI]);
        
        const radiusScale = d3.scaleLinear()
            .domain([0, 1])
            .range([0, radius]);
        
        // Draw grid circles
        for (let i = 1; i <= 5; i++) {
            svg.append('circle')
                .attr('cx', centerX)
                .attr('cy', centerY)
                .attr('r', radius * i / 5)
                .attr('fill', 'none')
                .attr('stroke', '#333')
                .attr('stroke-width', 1);
        }
        
        // Draw grid lines
        skills.forEach((skill, i) => {
            const angle = angleScale(i);
            const x = centerX + Math.cos(angle - Math.PI / 2) * radius;
            const y = centerY + Math.sin(angle - Math.PI / 2) * radius;
            
            svg.append('line')
                .attr('x1', centerX)
                .attr('y1', centerY)
                .attr('x2', x)
                .attr('y2', y)
                .attr('stroke', '#333')
                .attr('stroke-width', 1);
            
            // Add skill labels
            svg.append('text')
                .attr('x', x * 1.2)
                .attr('y', y * 1.2)
                .text(skill.name)
                .attr('text-anchor', 'middle')
                .attr('fill', '#fff')
                .attr('font-size', '12px');
        });
        
        // Draw skill values
        const line = d3.line()
            .x(d => centerX + Math.cos(d.angle - Math.PI / 2) * d.radius)
            .y(d => centerY + Math.sin(d.angle - Math.PI / 2) * d.radius)
            .curve(d3.curveLinearClosed);
        
        const skillData = skills.map((skill, i) => ({
            angle: angleScale(i),
            radius: radiusScale(skill.value)
        }));
        
        svg.append('path')
            .datum(skillData)
            .attr('d', line)
            .attr('fill', this.colors.primary)
            .attr('fill-opacity', 0.3)
            .attr('stroke', this.colors.primary)
            .attr('stroke-width', 2);
        
        // Add data points
        skillData.forEach(d => {
            svg.append('circle')
                .attr('cx', centerX + Math.cos(d.angle - Math.PI / 2) * d.radius)
                .attr('cy', centerY + Math.sin(d.angle - Math.PI / 2) * d.radius)
                .attr('r', 4)
                .attr('fill', this.colors.primary);
        });
    }
    
    createTimeHeatmap() {
        const heatmapContainer = this.container
            .append('div')
            .attr('class', 'heatmap-container')
            .style('width', '400px')
            .style('height', '200px')
            .style('float', 'left')
            .style('margin', '10px');
        
        const heatmapTitle = heatmapContainer
            .append('h3')
            .text('Learning Activity Heatmap')
            .style('text-align', 'center')
            .style('color', this.colors.secondary);
        
        const heatmapSvg = heatmapContainer
            .append('svg')
            .attr('width', 380)
            .attr('height', 150)
            .style('margin', '10px');
        
        this.visualizations.heatmap = heatmapSvg;
        this.updateTimeHeatmap();
    }
    
    updateTimeHeatmap() {
        const svg = this.visualizations.heatmap;
        const width = 380;
        const height = 150;
        const cellSize = 15;
        const padding = 5;
        
        // Clear previous content
        svg.selectAll('*').remove();
        
        // Generate sample data for the last 30 days
        const data = [];
        const today = new Date();
        for (let i = 29; i >= 0; i--) {
            const date = new Date(today);
            date.setDate(date.getDate() - i);
            
            for (let hour = 0; hour < 24; hour++) {
                data.push({
                    date: date,
                    hour: hour,
                    value: Math.random() * 100 // Simulated learning activity
                });
            }
        }
        
        // Create scales
        const xScale = d3.scaleBand()
            .domain(d3.range(24))
            .range([padding, width - padding])
            .padding(0.1);
        
        const yScale = d3.scaleBand()
            .domain(d3.range(30))
            .range([padding, height - padding])
            .padding(0.1);
        
        const colorScale = d3.scaleSequential(d3.interpolateBlues)
            .domain([0, 100]);
        
        // Create cells
        svg.selectAll('.heatmap-cell')
            .data(data)
            .enter()
            .append('rect')
            .attr('class', 'heatmap-cell')
            .attr('x', d => xScale(d.hour))
            .attr('y', d => yScale(29 - Math.floor((today - d.date) / (1000 * 60 * 60 * 24))))
            .attr('width', xScale.bandwidth())
            .attr('height', yScale.bandwidth())
            .attr('fill', d => colorScale(d.value))
            .attr('stroke', '#333')
            .attr('stroke-width', 0.5)
            .on('mouseover', function(event, d) {
                d3.select(this).attr('stroke', '#fff').attr('stroke-width', 2);
                
                // Show tooltip
                const tooltip = d3.select('body').append('div')
                    .attr('class', 'tooltip')
                    .style('position', 'absolute')
                    .style('background', 'rgba(0,0,0,0.8)')
                    .style('color', 'white')
                    .style('padding', '5px')
                    .style('border-radius', '3px')
                    .style('pointer-events', 'none')
                    .style('opacity', 0);
                
                tooltip.transition().duration(200).style('opacity', 1);
                tooltip.html(`
                    <strong>${d.date.toDateString()}</strong><br/>
                    Hour: ${d.hour}:00<br/>
                    Activity: ${Math.round(d.value)}%
                `)
                .style('left', (event.pageX + 10) + 'px')
                .style('top', (event.pageY - 10) + 'px');
            })
            .on('mouseout', function() {
                d3.select(this).attr('stroke', '#333').attr('stroke-width', 0.5);
                d3.selectAll('.tooltip').remove();
            });
        
        // Add hour labels
        svg.append('g')
            .attr('class', 'x-axis')
            .attr('transform', `translate(0, ${height - padding})`)
            .call(d3.axisBottom(xScale).tickValues([0, 6, 12, 18, 23]).tickFormat(d => d + ':00'));
        
        // Add day labels
        svg.append('g')
            .attr('class', 'y-axis')
            .attr('transform', `translate(${padding}, 0)`)
            .call(d3.axisLeft(yScale).tickValues([0, 7, 14, 21, 29]).tickFormat(d => {
                const date = new Date(today);
                date.setDate(date.getDate() - (29 - d));
                return date.getDate();
            }));
    }
    
    createSkillEvolution() {
        const evolutionContainer = this.container
            .append('div')
            .attr('class', 'evolution-container')
            .style('width', '500px')
            .style('height', '300px')
            .style('float', 'left')
            .style('margin', '10px');
        
        const evolutionTitle = evolutionContainer
            .append('h3')
            .text('Skill Evolution Over Time')
            .style('text-align', 'center')
            .style('color', this.colors.accent);
        
        const evolutionSvg = evolutionContainer
            .append('svg')
            .attr('width', 480)
            .attr('height', 250)
            .style('margin', '10px');
        
        this.visualizations.evolution = evolutionSvg;
        this.updateSkillEvolution();
    }
    
    updateSkillEvolution() {
        const svg = this.visualizations.evolution;
        const width = 480;
        const height = 250;
        const margin = { top: 20, right: 30, bottom: 40, left: 50 };
        const innerWidth = width - margin.left - margin.right;
        const innerHeight = height - margin.top - margin.bottom;
        
        // Clear previous content
        svg.selectAll('*').remove();
        
        // Generate sample data
        const skills = ['Python', 'PySpark', 'Git', 'Databricks', 'Data Analysis'];
        const weeks = d3.range(1, 13); // 12 weeks
        
        const data = skills.map(skill => ({
            name: skill,
            values: weeks.map(week => ({
                week: week,
                value: Math.min(1, Math.random() * 0.3 + (week / 12) * 0.7)
            }))
        }));
        
        // Create scales
        const xScale = d3.scaleLinear()
            .domain(d3.extent(weeks))
            .range([0, innerWidth]);
        
        const yScale = d3.scaleLinear()
            .domain([0, 1])
            .range([innerHeight, 0]);
        
        const colorScale = d3.scaleOrdinal()
            .domain(skills)
            .range([this.colors.primary, this.colors.secondary, this.colors.accent, '#ff0066', '#ffff00']);
        
        // Create line generator
        const line = d3.line()
            .x(d => xScale(d.week))
            .y(d => yScale(d.value))
            .curve(d3.curveMonotoneX);
        
        // Create area generator
        const area = d3.area()
            .x(d => xScale(d.week))
            .y0(innerHeight)
            .y1(d => yScale(d.value))
            .curve(d3.curveMonotoneX);
        
        // Create main group
        const g = svg.append('g')
            .attr('transform', `translate(${margin.left}, ${margin.top})`);
        
        // Add axes
        g.append('g')
            .attr('class', 'x-axis')
            .attr('transform', `translate(0, ${innerHeight})`)
            .call(d3.axisBottom(xScale).tickFormat(d => `Week ${d}`));
        
        g.append('g')
            .attr('class', 'y-axis')
            .call(d3.axisLeft(yScale).tickFormat(d3.format('.0%')));
        
        // Add skill lines
        data.forEach(skill => {
            const skillGroup = g.append('g')
                .attr('class', 'skill-group');
            
            // Add area
            skillGroup.append('path')
                .datum(skill.values)
                .attr('d', area)
                .attr('fill', colorScale(skill.name))
                .attr('fill-opacity', 0.2);
            
            // Add line
            skillGroup.append('path')
                .datum(skill.values)
                .attr('d', line)
                .attr('fill', 'none')
                .attr('stroke', colorScale(skill.name))
                .attr('stroke-width', 2);
            
            // Add data points
            skillGroup.selectAll('.data-point')
                .data(skill.values)
                .enter()
                .append('circle')
                .attr('class', 'data-point')
                .attr('cx', d => xScale(d.week))
                .attr('cy', d => yScale(d.value))
                .attr('r', 3)
                .attr('fill', colorScale(skill.name));
        });
        
        // Add legend
        const legend = g.append('g')
            .attr('class', 'legend')
            .attr('transform', `translate(${innerWidth - 100}, 20)`);
        
        skills.forEach((skill, i) => {
            const legendItem = legend.append('g')
                .attr('transform', `translate(0, ${i * 20})`);
            
            legendItem.append('rect')
                .attr('width', 15)
                .attr('height', 15)
                .attr('fill', colorScale(skill));
            
            legendItem.append('text')
                .attr('x', 20)
                .attr('y', 12)
                .text(skill)
                .attr('fill', '#fff')
                .attr('font-size', '12px');
        });
    }
    
    createCommunityNetwork() {
        const networkContainer = this.container
            .append('div')
            .attr('class', 'network-container')
            .style('width', '400px')
            .style('height', '300px')
            .style('float', 'left')
            .style('margin', '10px');
        
        const networkTitle = networkContainer
            .append('h3')
            .text('Learning Community Network')
            .style('text-align', 'center')
            .style('color', this.colors.success);
        
        const networkSvg = networkContainer
            .append('svg')
            .attr('width', 380)
            .attr('height', 250)
            .style('margin', '10px');
        
        this.visualizations.network = networkSvg;
        this.updateCommunityNetwork();
    }
    
    updateCommunityNetwork() {
        const svg = this.visualizations.network;
        const width = 380;
        const height = 250;
        
        // Clear previous content
        svg.selectAll('*').remove();
        
        // Generate sample network data
        const nodes = d3.range(20).map(i => ({
            id: i,
            group: Math.floor(i / 4),
            x: Math.random() * width,
            y: Math.random() * height,
            size: Math.random() * 10 + 5
        }));
        
        const links = [];
        nodes.forEach((node, i) => {
            if (i < nodes.length - 1) {
                links.push({
                    source: node,
                    target: nodes[i + 1],
                    strength: Math.random()
                });
            }
        });
        
        // Add some random connections
        for (let i = 0; i < 10; i++) {
            const source = nodes[Math.floor(Math.random() * nodes.length)];
            const target = nodes[Math.floor(Math.random() * nodes.length)];
            if (source !== target) {
                links.push({
                    source: source,
                    target: target,
                    strength: Math.random()
                });
            }
        }
        
        // Create simulation
        const simulation = d3.forceSimulation(nodes)
            .force('link', d3.forceLink(links).id(d => d.id).distance(50))
            .force('charge', d3.forceManyBody().strength(-100))
            .force('center', d3.forceCenter(width / 2, height / 2));
        
        // Create links
        svg.append('g')
            .attr('class', 'links')
            .selectAll('line')
            .data(links)
            .enter()
            .append('line')
            .attr('stroke', '#666')
            .attr('stroke-opacity', 0.6)
            .attr('stroke-width', d => d.strength * 3);
        
        // Create nodes
        const nodeGroup = svg.append('g')
            .attr('class', 'nodes')
            .selectAll('circle')
            .data(nodes)
            .enter()
            .append('circle')
            .attr('r', d => d.size)
            .attr('fill', d => d3.schemeCategory10[d.group])
            .attr('stroke', '#fff')
            .attr('stroke-width', 2)
            .call(d3.drag()
                .on('start', dragstarted)
                .on('drag', dragged)
                .on('end', dragended));
        
        // Add labels
        svg.append('g')
            .attr('class', 'labels')
            .selectAll('text')
            .data(nodes)
            .enter()
            .append('text')
            .text(d => `L${d.id}`)
            .attr('x', d => d.x)
            .attr('y', d => d.y)
            .attr('text-anchor', 'middle')
            .attr('fill', '#fff')
            .attr('font-size', '10px');
        
        // Update positions on simulation tick
        simulation.on('tick', () => {
            svg.selectAll('.links line')
                .attr('x1', d => d.source.x)
                .attr('y1', d => d.source.y)
                .attr('x2', d => d.target.x)
                .attr('y2', d => d.target.y);
            
            svg.selectAll('.nodes circle')
                .attr('cx', d => d.x)
                .attr('cy', d => d.y);
            
            svg.selectAll('.labels text')
                .attr('x', d => d.x)
                .attr('y', d => d.y);
        });
        
        // Drag functions
        function dragstarted(event, d) {
            if (!event.active) simulation.alphaTarget(0.3).restart();
            d.fx = d.x;
            d.fy = d.y;
        }
        
        function dragged(event, d) {
            d.fx = event.x;
            d.fy = event.y;
        }
        
        function dragended(event, d) {
            if (!event.active) simulation.alphaTarget(0);
            d.fx = null;
            d.fy = null;
        }
    }
    
    createEngagementGauge() {
        const gaugeContainer = this.container
            .append('div')
            .attr('class', 'gauge-container')
            .style('width', '200px')
            .style('height', '200px')
            .style('float', 'left')
            .style('margin', '10px');
        
        const gaugeTitle = gaugeContainer
            .append('h3')
            .text('Engagement Level')
            .style('text-align', 'center')
            .style('color', this.colors.warning);
        
        const gaugeSvg = gaugeContainer
            .append('svg')
            .attr('width', 180)
            .attr('height', 150)
            .style('margin', '10px');
        
        this.visualizations.gauge = gaugeSvg;
        this.updateEngagementGauge();
    }
    
    updateEngagementGauge() {
        const svg = this.visualizations.gauge;
        const width = 180;
        const height = 150;
        const centerX = width / 2;
        const centerY = height / 2;
        const radius = 60;
        
        // Clear previous content
        svg.selectAll('*').remove();
        
        // Sample engagement value (0-100)
        const engagementValue = 75;
        
        // Create arc generator
        const arc = d3.arc()
            .innerRadius(radius - 20)
            .outerRadius(radius)
            .startAngle(0)
            .endAngle(2 * Math.PI);
        
        // Background arc
        svg.append('path')
            .attr('d', arc)
            .attr('transform', `translate(${centerX}, ${centerY})`)
            .attr('fill', '#333')
            .attr('stroke', '#666')
            .attr('stroke-width', 2);
        
        // Value arc
        const valueArc = d3.arc()
            .innerRadius(radius - 20)
            .outerRadius(radius)
            .startAngle(0)
            .endAngle(2 * Math.PI * (engagementValue / 100));
        
        svg.append('path')
            .attr('d', valueArc)
            .attr('transform', `translate(${centerX}, ${centerY})`)
            .attr('fill', this.getEngagementColor(engagementValue))
            .attr('stroke', '#fff')
            .attr('stroke-width', 2);
        
        // Center text
        svg.append('text')
            .attr('x', centerX)
            .attr('y', centerY - 10)
            .text(`${engagementValue}%`)
            .attr('text-anchor', 'middle')
            .attr('fill', '#fff')
            .attr('font-size', '24px')
            .attr('font-weight', 'bold');
        
        svg.append('text')
            .attr('x', centerX)
            .attr('y', centerY + 15)
            .text('Engaged')
            .attr('text-anchor', 'middle')
            .attr('fill', '#fff')
            .attr('font-size', '12px');
    }
    
    getEngagementColor(value) {
        if (value >= 80) return this.colors.success;
        if (value >= 60) return this.colors.warning;
        return this.colors.danger;
    }
    
    setupEventListeners() {
        // Listen for data updates
        window.addEventListener('learningDataUpdate', (event) => {
            this.updateData(event.detail);
        });
        
        // Listen for module selection
        window.addEventListener('moduleSelected', (event) => {
            this.highlightModule(event.detail.moduleId);
        });
    }
    
    updateData(newData) {
        this.data = { ...this.data, ...newData };
        this.refreshAllVisualizations();
    }
    
    refreshAllVisualizations() {
        this.updateRadarChart();
        this.updateTimeHeatmap();
        this.updateSkillEvolution();
        this.updateCommunityNetwork();
        this.updateEngagementGauge();
    }
    
    highlightModule(moduleId) {
        // Highlight relevant data in visualizations
        console.log(`Highlighting module: ${moduleId}`);
    }
    
    // Public API methods
    getVisualizationData() {
        return {
            radar: this.getRadarData(),
            heatmap: this.getHeatmapData(),
            evolution: this.getEvolutionData(),
            network: this.getNetworkData(),
            gauge: this.getGaugeData()
        };
    }
    
    getRadarData() {
        // Return current radar chart data
        return {
            skills: [
                { name: 'Python', value: 0.8 },
                { name: 'PySpark', value: 0.6 },
                { name: 'Git', value: 0.7 },
                { name: 'Databricks', value: 0.3 },
                { name: 'Data Analysis', value: 0.9 },
                { name: 'Visualization', value: 0.5 }
            ]
        };
    }
    
    getHeatmapData() {
        // Return current heatmap data
        return {
            activity: this.generateActivityData()
        };
    }
    
    getEvolutionData() {
        // Return current evolution data
        return {
            skills: ['Python', 'PySpark', 'Git', 'Databricks', 'Data Analysis'],
            weeks: d3.range(1, 13)
        };
    }
    
    getNetworkData() {
        // Return current network data
        return {
            nodes: [],
            links: []
        };
    }
    
    getGaugeData() {
        // Return current gauge data
        return {
            engagement: 75
        };
    }
    
    generateActivityData() {
        // Generate sample activity data
        const data = [];
        const today = new Date();
        for (let i = 29; i >= 0; i--) {
            const date = new Date(today);
            date.setDate(date.getDate() - i);
            for (let hour = 0; hour < 24; hour++) {
                data.push({
                    date: date,
                    hour: hour,
                    value: Math.random() * 100
                });
            }
        }
        return data;
    }
}

// Export for use in other modules
export default LearningDashboard;

// Example usage
document.addEventListener('DOMContentLoaded', () => {
    const dashboard = new LearningDashboard('learning-dashboard');
    
    // Simulate data updates
    setInterval(() => {
        const event = new CustomEvent('learningDataUpdate', {
            detail: {
                engagement: Math.random() * 100,
                skills: {
                    python: Math.random(),
                    pyspark: Math.random(),
                    git: Math.random()
                }
            }
        });
        window.dispatchEvent(event);
    }, 5000);
});

