const express = require('express');
const cors = require('cors');
const cron = require('node-cron');
const waClient = require('./wa_client');

const app = express();
const PORT = process.env.PORT || 3000;
const DEFAULT_RECIPIENT = process.env.WHATSAPP_TARGET_PHONE || '6281200000000';

app.use(cors());
app.use(express.json());

// Initialize Baileys WhatsApp bot
waClient.initialize();

// --- Health & Connection Status ---
app.get('/api/status', (req, res) => {
  res.json({
    service: 'ZenithOS Backend Automation',
    status: 'online',
    whatsappConnected: waClient.isConnected,
    timestamp: new Date().toISOString(),
  });
});

app.get('/api/qr', (req, res) => {
  if (waClient.isConnected) {
    return res.json({ connected: true, message: 'WhatsApp already connected.' });
  }
  res.json({
    connected: false,
    qrCode: waClient.qrCode,
    message: waClient.qrCode ? 'Scan QR in terminal or via web QR renderer.' : 'Generating QR code...',
  });
});

// --- Inbound Alarm Webhook Trigger from Flutter Web ---
app.post('/api/alarm', async (req, res) => {
  const { id, title, description, isStrictBedtime, triggerTime, recipientPhone } = req.body;
  const target = recipientPhone || DEFAULT_RECIPIENT;

  console.log(`\n[Zenith Webhook] Alarm Received [ID: ${id}]`);
  console.log(`Title: ${title}`);
  console.log(`Description: ${description}`);
  console.log(`Strict Sleep: ${isStrictBedtime}`);

  const formattedMsg = `*🚨 [ZENITHOS DISCIPLINE ALERT]*\n\n*${title}*\n${description}\n\n_Scheduled Time: ${triggerTime || new Date().toLocaleTimeString()}_`;

  const success = await waClient.sendReminder(target, formattedMsg);

  res.json({
    success: true,
    alarmId: id,
    dispatchedToWhatsApp: success,
    timestamp: new Date().toISOString(),
  });
});

// --- Scheduled Bedtime Alarms (Node-Cron Automation) ---

// 1. 22:30 Soft Reminder (Save commit, close laptop, shut down IDE)
cron.schedule('30 22 * * *', async () => {
  console.log('[Zenith Cron] Triggering 22:30 Soft Reminder...');
  const msg = `*🛡️ [ZENITH SOFT CUT-OFF: 22:30]*\n\n1. Commit & push all active branches.\n2. Wrap up IaC / Kubernetes configs.\n3. Shut down IDE and laptop screen.\n4. Prepare for 23:00 hard bedtime.`;
  await waClient.sendReminder(DEFAULT_RECIPIENT, msg);
});

// 2. 23:00 Strict Sleep Alarm (Recovery 6 hours -> 05:00 wake)
cron.schedule('0 23 * * *', async () => {
  console.log('[Zenith Cron] Triggering 23:00 Hard Bedtime Alarm...');
  const msg = `*⚡ [ZENITH HARD SLEEP WINDOW: 23:00]*\n\nImmediate cellular recovery begins.\nTarget: 6 hours deep sleep until 05:00 wake.\n\n_Discipline equals freedom._`;
  await waClient.sendReminder(DEFAULT_RECIPIENT, msg);
});

app.listen(PORT, () => {
  console.log(`\n🚀 ZenithOS Automation Backend running on http://localhost:${PORT}`);
  console.log(`Webhook endpoint ready: http://localhost:${PORT}/api/alarm`);
});
