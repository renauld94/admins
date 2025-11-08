#!/usr/bin/env node
/**
 * Headless QA for Portfolio - Desktop & Mobile Emulation
 * Captures console logs, checks for errors, and verifies performance
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

(async () => {
    const results = {
        desktop: {},
        mobile: {},
        timestamp: new Date().toISOString()
    };

    // Launch browser
    const browser = await puppeteer.launch({
        headless: 'new',
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    try {
        // ========== DESKTOP TEST ==========
        console.log('🖥️  Testing DESKTOP version...');
        const desktopPage = await browser.newPage();
        const desktopLogs = [];
        const desktopErrors = [];

        desktopPage.on('console', msg => {
            const text = msg.text();
            desktopLogs.push({ level: msg.type(), text });
            if (msg.type() === 'error' || msg.type() === 'warning') {
                console.log(`  [${msg.type().toUpperCase()}] ${text}`);
            }
        });

        desktopPage.on('error', err => {
            desktopErrors.push(err.toString());
            console.error(`  ❌ Page error:`, err);
        });

        desktopPage.on('pageerror', err => {
            desktopErrors.push(err.toString());
            console.error(`  ❌ Page error:`, err);
        });

        await desktopPage.goto('https://www.simondatalab.de/', {
            waitUntil: 'networkidle2',
            timeout: 30000
        });

        // Wait for hero viz to mount
        await new Promise(resolve => setTimeout(resolve, 5000));

        // Capture metrics
        const desktopMetrics = await desktopPage.evaluate(() => {
            const perfSample = localStorage.getItem('simon_perf_last_sample');
            return {
                heroMounted: !!window.heroVisualization,
                lowPowerMode: window.__SIMON_LOW_POWER_MODE__,
                maxDPR: window.__SIMON_MAX_DEVICE_PIXEL_RATIO__,
                perfSample: perfSample ? JSON.parse(perfSample) : null,
                innerWidth: window.innerWidth,
                innerHeight: window.innerHeight,
                devicePixelRatio: window.devicePixelRatio
            };
        });

        results.desktop = {
            metrics: desktopMetrics,
            consoleLogs: desktopLogs,
            errors: desktopErrors,
            screenshot: await desktopPage.screenshot({ path: '/tmp/desktop-screenshot.png' })
        };

        console.log('✅ Desktop test complete');
        console.log(`   Hero mounted: ${desktopMetrics.heroMounted}`);
        console.log(`   Low-power mode: ${desktopMetrics.lowPowerMode}`);
        if (desktopMetrics.perfSample) {
            console.log(`   FPS sample: ${desktopMetrics.perfSample.fps}`);
        }

        await desktopPage.close();

        // ========== MOBILE TEST ==========
        console.log('\n📱 Testing MOBILE emulation...');
        const mobilePage = await browser.newPage();
        const mobileLogs = [];
        const mobileErrors = [];

        // Emulate iPhone 12
        await mobilePage.emulateMediaFeatures([
            { name: 'prefers-color-scheme', value: 'dark' }
        ]);
        await mobilePage.setViewport({
            width: 390,
            height: 844,
            deviceScaleFactor: 3,
            mobile: true,
            hasTouch: true
        });

        mobilePage.on('console', msg => {
            const text = msg.text();
            mobileLogs.push({ level: msg.type(), text });
            if (msg.type() === 'error' || msg.type() === 'warning') {
                console.log(`  [${msg.type().toUpperCase()}] ${text}`);
            }
        });

        mobilePage.on('error', err => {
            mobileErrors.push(err.toString());
            console.error(`  ❌ Page error:`, err);
        });

        mobilePage.on('pageerror', err => {
            mobileErrors.push(err.toString());
            console.error(`  ❌ Page error:`, err);
        });

        await mobilePage.goto('https://www.simondatalab.de/', {
            waitUntil: 'networkidle2',
            timeout: 30000
        });

        // Wait for hero viz to mount
        await new Promise(resolve => setTimeout(resolve, 5000));

        // Capture metrics
        const mobileMetrics = await mobilePage.evaluate(() => {
            const perfSample = localStorage.getItem('simon_perf_last_sample');
            return {
                heroMounted: !!window.heroVisualization,
                lowPowerMode: window.__SIMON_LOW_POWER_MODE__,
                maxDPR: window.__SIMON_MAX_DEVICE_PIXEL_RATIO__,
                perfSample: perfSample ? JSON.parse(perfSample) : null,
                innerWidth: window.innerWidth,
                innerHeight: window.innerHeight,
                devicePixelRatio: window.devicePixelRatio,
                userAgent: navigator.userAgent
            };
        });

        results.mobile = {
            metrics: mobileMetrics,
            consoleLogs: mobileLogs,
            errors: mobileErrors,
            screenshot: await mobilePage.screenshot({ path: '/tmp/mobile-screenshot.png' })
        };

        console.log('✅ Mobile test complete');
        console.log(`   Hero mounted: ${mobileMetrics.heroMounted}`);
        console.log(`   Low-power mode: ${mobileMetrics.lowPowerMode}`);
        if (mobileMetrics.perfSample) {
            console.log(`   FPS sample: ${mobileMetrics.perfSample.fps}`);
        }

        await mobilePage.close();

    } catch (error) {
        console.error('❌ QA failed:', error);
        results.error = error.toString();
    } finally {
        await browser.close();
    }

    // Save results
    const reportPath = '/tmp/qa-results.json';
    fs.writeFileSync(reportPath, JSON.stringify(results, null, 2));
    console.log(`\n📋 Full results saved to: ${reportPath}`);

    // Print summary
    console.log('\n' + '='.repeat(60));
    console.log('🧪 QA SUMMARY');
    console.log('='.repeat(60));
    console.log(JSON.stringify({
        desktop: {
            heroMounted: results.desktop.metrics?.heroMounted,
            lowPowerMode: results.desktop.metrics?.lowPowerMode,
            fps: results.desktop.metrics?.perfSample?.fps,
            errors: results.desktop.errors.length
        },
        mobile: {
            heroMounted: results.mobile.metrics?.heroMounted,
            lowPowerMode: results.mobile.metrics?.lowPowerMode,
            fps: results.mobile.metrics?.perfSample?.fps,
            errors: results.mobile.errors.length
        }
    }, null, 2));

    process.exit(0);
})();
