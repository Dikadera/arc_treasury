import { generateEntitySecret, registerEntitySecretCiphertext } from "@circle-fin/developer-controlled-wallets";
import fs from 'fs';

// Helper to read the API key from .env.local
const envLocal = fs.readFileSync('.env.local', 'utf-8');
const apiKeyMatch = envLocal.match(/CIRCLE_API_KEY=(.*)/);
const apiKey = apiKeyMatch ? apiKeyMatch[1].trim() : '';

if (!apiKey || apiKey === 'your-circle-api-key') {
  console.error("Error: Please put your real CIRCLE_API_KEY in .env.local first!");
  process.exit(1);
}

async function setup() {
  console.log("Generating Entity Secret...");
  const secret = generateEntitySecret();
  console.log("\n--- COPY THIS SECRET INTO YOUR .env.local FILE ---");
  console.log(`CIRCLE_ENTITY_SECRET=${secret}`);
  console.log("--------------------------------------------------\n");

  console.log("Registering secret with Circle...");
  try {
    const response = await registerEntitySecretCiphertext({
      apiKey: apiKey,
      entitySecret: secret,
      recoveryFileDownloadPath: "./recovery",
    });
    console.log("Successfully registered! A recovery file has been saved to the ./recovery folder.");
    console.log("Make sure to keep the recovery file safe and do NOT commit it to GitHub.");
  } catch (error) {
    console.error("Failed to register secret:", error.message);
  }
}

setup();
