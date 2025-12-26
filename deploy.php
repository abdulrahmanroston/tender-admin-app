<?php
/**
 * GitHub Webhook Auto-Deploy Handler (Simplified Version)
 * 
 * This script handles automatic deployment when GitHub sends a push event.
 * Works out of the box without requiring secret token configuration.
 * 
 * @author Auto-Deploy System
 * @version 2.0.0
 */

// Configuration
define('DEPLOY_SCRIPT', __DIR__ . '/deploy.sh');
define('LOG_FILE', __DIR__ . '/deploy.log');
define('BRANCH_TO_DEPLOY', 'main');

// Function to log messages
function logMessage($message, $level = 'INFO') {
    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[{$timestamp}] [{$level}] {$message}" . PHP_EOL;
    file_put_contents(LOG_FILE, $logEntry, FILE_APPEND);
}

// Function to send response and exit
function sendResponse($statusCode, $message) {
    http_response_code($statusCode);
    logMessage($message, $statusCode >= 400 ? 'ERROR' : 'INFO');
    echo json_encode(['status' => $statusCode, 'message' => $message]);
    exit;
}

// Start processing
logMessage('Webhook received from IP: ' . ($_SERVER['REMOTE_ADDR'] ?? 'unknown'));

// Verify request method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(405, 'Method not allowed. Only POST requests are accepted.');
}

// Get payload
$payload = file_get_contents('php://input');
if (empty($payload)) {
    sendResponse(400, 'Empty payload received.');
}

logMessage('Valid POST request received');

// Parse payload
$data = json_decode($payload, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    sendResponse(400, 'Invalid JSON payload.');
}

// Verify it's from GitHub (check user agent)
$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';
if (stripos($userAgent, 'GitHub-Hookshot') === false) {
    logMessage("Warning: Request not from GitHub. User-Agent: {$userAgent}", 'WARNING');
}

// Check if it's a push event
$event = $_SERVER['HTTP_X_GITHUB_EVENT'] ?? '';
if ($event !== 'push') {
    sendResponse(200, "Event '{$event}' ignored. Only push events trigger deployment.");
}

// Verify branch
$ref = $data['ref'] ?? '';
$branch = str_replace('refs/heads/', '', $ref);

if ($branch !== BRANCH_TO_DEPLOY) {
    sendResponse(200, "Branch '{$branch}' ignored. Only '{BRANCH_TO_DEPLOY}' branch triggers deployment.");
}

logMessage("Push event detected on branch '{$branch}'");

// Get commit information
$commitMessage = $data['head_commit']['message'] ?? 'No commit message';
$committer = $data['head_commit']['committer']['name'] ?? 'Unknown';
$commitSha = isset($data['head_commit']['id']) ? substr($data['head_commit']['id'], 0, 7) : 'unknown';
$repoName = $data['repository']['full_name'] ?? 'Unknown repository';

logMessage("Repository: {$repoName}");
logMessage("Commit: [{$commitSha}] by {$committer} - {$commitMessage}");

// Execute deployment script
if (!file_exists(DEPLOY_SCRIPT)) {
    sendResponse(500, 'Deployment script not found.');
}

if (!is_executable(DEPLOY_SCRIPT)) {
    chmod(DEPLOY_SCRIPT, 0755);
    logMessage('Made deployment script executable');
}

logMessage('Executing deployment script...');

$output = [];
$returnCode = 0;
exec(DEPLOY_SCRIPT . ' 2>&1', $output, $returnCode);

$outputText = implode("\n", $output);
logMessage("Deployment output:\n" . $outputText);

if ($returnCode === 0) {
    logMessage('Deployment completed successfully');
    sendResponse(200, 'Deployment successful!');
} else {
    logMessage("Deployment failed with exit code: {$returnCode}", 'ERROR');
    sendResponse(500, 'Deployment failed. Check logs for details.');
}
