#!/usr/bin/env node

/**
 * AdmasAfroLink Integration Test Script
 * Tests frontend-backend integration
 */

const https = require('https');
const http = require('http');

// Test configuration
const tests = {
  frontend: {
    url: 'http://localhost:3000',
    name: 'Frontend Website'
  },
  api: {
    url: 'http://localhost:7001/api/health',
    name: 'Backend API Health'
  },
  apiInfo: {
    url: 'http://localhost:7001/api/info',
    name: 'Backend API Info'
  }
};

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
  console.log(colors[color] + message + colors.reset);
}

function makeRequest(url, method = 'GET') {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const requestModule = urlObj.protocol === 'https:' ? https : http;
    
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port,
      path: urlObj.pathname,
      method: method,
      timeout: 5000,
      headers: {
        'User-Agent': 'AdmasAfroLink-Integration-Test'
      }
    };

    const req = requestModule.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: data
        });
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });

    req.end();
  });
}

async function testEndpoint(name, url) {
  log(`Testing ${name}...`, 'cyan');
  
  try {
    const response = await makeRequest(url);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      log(`✅ ${name} - OK (${response.statusCode})`, 'green');
      return true;
    } else {
      log(`❌ ${name} - Failed (${response.statusCode})`, 'red');
      return false;
    }
  } catch (error) {
    log(`❌ ${name} - Error: ${error.message}`, 'red');
    return false;
  }
}

async function testIntegration() {
  log('\n🚀 AdmasAfroLink Integration Test Suite', 'bright');
  log('===========================================\n', 'bright');
  
  const results = [];
  
  // Test each endpoint
  for (const [key, test] of Object.entries(tests)) {
    const result = await testEndpoint(test.name, test.url);
    results.push({ name: test.name, success: result });
    
    // Small delay between tests
    await new Promise(resolve => setTimeout(resolve, 500));
  }
  
  // Test API functionality
  log('\nTesting API Functionality...', 'cyan');
  
  try {
    // Test API endpoints that should exist
    const apiTests = [
      { endpoint: '/api/programs', name: 'Programs API' },
      { endpoint: '/api/applications', name: 'Applications API' },
      { endpoint: '/api/team/members', name: 'Team API' }
    ];
    
    for (const apiTest of apiTests) {
      try {
        const response = await makeRequest(`http://localhost:7001${apiTest.endpoint}`);
        if (response.statusCode === 200 || response.statusCode === 401) {
          log(`✅ ${apiTest.name} - Endpoint exists`, 'green');
          results.push({ name: apiTest.name, success: true });
        } else {
          log(`⚠️  ${apiTest.name} - Unexpected status (${response.statusCode})`, 'yellow');
          results.push({ name: apiTest.name, success: false });
        }
      } catch (error) {
        log(`❌ ${apiTest.name} - Error: ${error.message}`, 'red');
        results.push({ name: apiTest.name, success: false });
      }
      
      await new Promise(resolve => setTimeout(resolve, 300));
    }
  } catch (error) {
    log(`❌ API functionality test failed: ${error.message}`, 'red');
  }
  
  // Test JavaScript API integration
  log('\nTesting Frontend-Backend Integration...', 'cyan');
  
  try {
    const frontendResponse = await makeRequest('http://localhost:3000');
    
    if (frontendResponse.body.includes('apiService') || frontendResponse.body.includes('AdmasAfroLinkAPI')) {
      log('✅ Frontend API integration detected', 'green');
      results.push({ name: 'Frontend API Integration', success: true });
    } else {
      log('⚠️  Frontend API integration not detected in HTML', 'yellow');
      results.push({ name: 'Frontend API Integration', success: false });
    }
  } catch (error) {
    log(`❌ Frontend integration test failed: ${error.message}`, 'red');
    results.push({ name: 'Frontend API Integration', success: false });
  }
  
  // Summary
  log('\n📊 Test Results Summary', 'bright');
  log('========================\n', 'bright');
  
  const successful = results.filter(r => r.success).length;
  const total = results.length;
  
  results.forEach(result => {
    const status = result.success ? '✅' : '❌';
    const color = result.success ? 'green' : 'red';
    log(`${status} ${result.name}`, color);
  });
  
  log(`\nOverall: ${successful}/${total} tests passed`, successful === total ? 'green' : 'yellow');
  
  if (successful === total) {
    log('\n🎉 All integration tests passed! The platform is ready.', 'green');
  } else {
    log('\n⚠️  Some tests failed. Check the logs above for details.', 'yellow');
  }
  
  // Additional information
  log('\n🌐 Service URLs:', 'bright');
  log('Frontend: http://localhost:3000', 'cyan');
  log('API: http://localhost:7001', 'cyan');
  log('pgAdmin: http://localhost:5050', 'cyan');
  log('Redis Commander: http://localhost:8081', 'cyan');
  
  return successful === total;
}

// Run tests
if (require.main === module) {
  testIntegration()
    .then(success => {
      process.exit(success ? 0 : 1);
    })
    .catch(error => {
      log(`Fatal error: ${error.message}`, 'red');
      process.exit(1);
    });
}

module.exports = { testIntegration };
