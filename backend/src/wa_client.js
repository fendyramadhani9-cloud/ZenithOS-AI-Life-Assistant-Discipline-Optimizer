const {
  default: makeWASocket,
  DisconnectReason,
  useMultiFileAuthState,
  fetchLatestBaileysVersion,
} = require('@whiskeysockets/baileys');
const pino = require('pino');
const qrcode = require('qrcode-terminal');
const path = require('path');
const fs = require('fs');

class WhatsAppClient {
  constructor() {
    this.sock = null;
    this.qrCode = null;
    this.isConnected = false;
    this.authDir = path.join(__dirname, '../auth_info');

    if (!fs.existsSync(this.authDir)) {
      fs.mkdirSync(this.authDir, { recursive: true });
    }
  }

  async initialize() {
    try {
      const { state, saveCreds } = await useMultiFileAuthState(this.authDir);
      const { version } = await fetchLatestBaileysVersion();

      console.log(`[Zenith WA] Initializing Baileys v${version.join('.')}...`);

      this.sock = makeWASocket({
        version,
        logger: pino({ level: 'silent' }),
        printQRInTerminal: false,
        auth: state,
        browser: ['ZenithOS Discipline Bot', 'Chrome', '1.0.0'],
      });

      this.sock.ev.on('connection.update', (update) => {
        const { connection, lastDisconnect, qr } = update;

        if (qr) {
          this.qrCode = qr;
          console.log('\n[Zenith WA] Scan QR Code below to pair WhatsApp:');
          qrcode.generate(qr, { small: true });
        }

        if (connection === 'close') {
          this.isConnected = false;
          const shouldReconnect =
            lastDisconnect?.error?.output?.statusCode !== DisconnectReason.loggedOut;
          console.log(
            `[Zenith WA] Connection closed (${lastDisconnect?.error?.message}). Reconnecting: ${shouldReconnect}`
          );
          if (shouldReconnect) {
            this.initialize();
          }
        } else if (connection === 'open') {
          this.isConnected = true;
          this.qrCode = null;
          console.log('[Zenith WA] WhatsApp bot connected successfully & ready to dispatch reminders!');
        }
      });

      this.sock.ev.on('creds.update', saveCreds);
    } catch (err) {
      console.error('[Zenith WA] Initialization error:', err);
    }
  }

  async sendReminder(targetPhone, message) {
    if (!this.isConnected || !this.sock) {
      console.log(`[Zenith WA] Bot not connected. Logged message: "${message}"`);
      return false;
    }

    try {
      // Format number to WhatsApp JID (e.g. 628123456789@s.whatsapp.net)
      const cleanNumber = targetPhone.replace(/[^0-9]/g, '');
      const jid = `${cleanNumber}@s.whatsapp.net`;

      await this.sock.sendMessage(jid, { text: message });
      console.log(`[Zenith WA] Dispatched reminder to ${cleanNumber}`);
      return true;
    } catch (err) {
      console.error('[Zenith WA] Failed sending message:', err);
      return false;
    }
  }
}

module.exports = new WhatsAppClient();
