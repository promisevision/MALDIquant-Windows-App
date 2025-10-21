// Diagnostic script to test R installation
const { spawn, execSync } = require('child_process');
const path = require('path');

console.log('=== R Diagnostic Tool ===\n');

// Test 1: Check if R is in PATH
console.log('Test 1: Checking R in PATH...');
try {
  const output = execSync('where R', { encoding: 'utf8' });
  console.log('✓ R found in PATH:');
  console.log(output);
} catch (e) {
  console.log('✗ R not found in PATH');
  console.log('Error:', e.message);
}

// Test 2: Check R version
console.log('\nTest 2: Checking R version...');
try {
  const output = execSync('R --version', { encoding: 'utf8', timeout: 10000 });
  console.log('✓ R version:');
  console.log(output);
} catch (e) {
  console.log('✗ R version check failed');
  console.log('Error:', e.message);
}

// Test 3: Simple R command
console.log('\nTest 3: Testing simple R command...');
try {
  const output = execSync('R --vanilla --quiet -e "cat(\\"R is working\\\\n\\")"', {
    encoding: 'utf8',
    timeout: 10000
  });
  console.log('✓ Simple R command works:');
  console.log(output);
} catch (e) {
  console.log('✗ Simple R command failed');
  console.log('Error:', e.message);
  if (e.stderr) console.log('Stderr:', e.stderr.toString());
}

// Test 4: Check Rscript
console.log('\nTest 4: Checking Rscript...');
try {
  const output = execSync('Rscript --version', { encoding: 'utf8', timeout: 10000 });
  console.log('✓ Rscript found:');
  console.log(output);
} catch (e) {
  console.log('✗ Rscript not found');
  console.log('Error:', e.message);
}

// Test 5: Test with spawn (like Electron does)
console.log('\nTest 5: Testing R with spawn (Electron method)...');
const rProcess = spawn('R', ['--vanilla', '--quiet', '-e', 'cat("Spawn test successful\\n")'], {
  stdio: ['ignore', 'pipe', 'pipe']
});

let stdout = '';
let stderr = '';

rProcess.stdout.on('data', (data) => {
  stdout += data.toString();
});

rProcess.stderr.on('data', (data) => {
  stderr += data.toString();
});

rProcess.on('error', (error) => {
  console.log('✗ Spawn error:', error.message);
});

rProcess.on('close', (code) => {
  console.log(`Exit code: ${code}`);
  if (stdout) console.log('Stdout:', stdout);
  if (stderr) console.log('Stderr:', stderr);

  if (code === 0) {
    console.log('✓ Spawn test successful');
  } else {
    console.log('✗ Spawn test failed');
    console.log('\nPossible issues:');
    console.log('- R may be a wrapper script that doesn\'t work in MINGW');
    console.log('- Try using R.exe or Rscript.exe instead');
    console.log('- Check if R installation is complete');
  }

  // Test 6: Try to find R.exe directly
  console.log('\nTest 6: Searching for R.exe...');
  const fs = require('fs');
  const programFiles = process.env.ProgramFiles || 'C:\\Program Files';
  const rBaseDir = path.join(programFiles, 'R');

  if (fs.existsSync(rBaseDir)) {
    console.log('Found R directory:', rBaseDir);
    const rVersions = fs.readdirSync(rBaseDir).filter(name => name.startsWith('R-'));
    console.log('R versions found:', rVersions);

    if (rVersions.length > 0) {
      const latestVersion = rVersions.sort().reverse()[0];
      const rExePath = path.join(rBaseDir, latestVersion, 'bin', 'x64', 'R.exe');
      console.log('Expected R.exe path:', rExePath);
      console.log('R.exe exists:', fs.existsSync(rExePath));

      if (fs.existsSync(rExePath)) {
        console.log('\nRecommendation: Use full path to R.exe instead of "R"');
        console.log('Path to use:', rExePath);
      }
    }
  }
});
