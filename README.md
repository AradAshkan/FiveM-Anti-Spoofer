# 🚨 Arad's Setwarn & Anti-Cheat System 🛡️

Welcome to **Arad's Setwarn & Anti-Cheat System**, a powerful Lua script designed for **FiveM** servers using the **ESX framework**. This system allows server admins to manage player warnings and detect potential spoofers with ease, all while integrating seamlessly with your MySQL database and Discord for alerts! 🎉

## ✨ Features

- **Setwarn Command** 📝
  - Admins can issue warnings to players using their Steam Hex.
  - Supports adding, updating, and removing warnings.
  - Displays warnings to admins every 5 seconds for active warned players.
  - Usage: `/setwarn [SteamHex] [Warn Text]` or `/setwarn [SteamHex]` to remove.

- **Anti-Cheat System** 🔍
  - Monitors player HWIDs to detect potential spoofers.
  - Compares player HWIDs against a `banlist` table in the database.
  - Alerts admins in-game and sends notifications to a Discord webhook when a suspicious player is detected.

- **Database Integration** 🗄️
  - Stores warnings in a `setwarn` table with details like Steam Hex, warning note, admin name, and timestamp.
  - Supports checking for banned HWIDs in a `banlist` table.

- **Discord Webhook Alerts** 📢
  - Sends real-time notifications to your Discord server when a spoofer is detected.

## 🛠️ Installation

1. **Clone the Repository** 📥
   ```bash
   git clone https://github.com/aradashkan/FiveM-Anti-Spoofer.git
   ```

2. **Add to Your Server** 🖥️
   - Copy the script folder to your server's `resources` directory.
   - Add `ensure Anti-Spoofer` to your `server.cfg`.

3. **Set Up the Database** 🗃️
   - Import the provided `setwarn.sql` file into your MySQL database to create the `setwarn` table.
   - Ensure your `banlist` table exists with a `hwid` column for the anti-cheat system.

4. **Configure Discord Webhook** 🌐
   - Replace `"Your_Discord_Webhook_URL_Here"` in the script with your actual Discord webhook URL.

5. **Restart Your Server** 🔄
   - Restart your FiveM server or use `refresh` followed by `start Anti-Spoofer`.

## 📚 Database Setup

The script requires a MySQL database with the following tables:

### `setwarn` Table
Stores player warnings with details.

```sql
CREATE TABLE IF NOT EXISTS `setwarn` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `note` text DEFAULT NULL,
  `admin` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

### `banlist` Table
Stores banned HWIDs for the anti-cheat system (ensure it has a `hwid` column).

## 🎮 Usage

- **Set a Warning**:
  ```bash
  /setwarn steam:1100001xxxxxxx "Breaking server rules"
  ```

- **Remove a Warning**:
  ```bash
  /setwarn steam:1100001xxxxxxx
  ```

- **Admin Notifications**:
  - Admins with `permission_level > 0` receive in-game warnings every 5 seconds for active warned players.
  - Spoofer alerts are sent to admins and Discord when a player's HWID matches a banned one.

## 🛡️ Permissions

- The `/setwarn` command requires admin level 5 (`es:addAdminCommand` level 5).
- Only admins with `permission_level > 0` receive warning and spoofer alerts.

## 🌟 Contributing

Contributions are welcome! 🙌 Feel free to open issues or submit pull requests to improve the script. Make sure to follow the code style and test your changes.

## 📜 License

This project is licensed under the [MIT License](LICENSE.md). See the LICENSE file for details.

## 🙏 Credits

- **Coded by Aяad** 💻
- GitHub: [aradashkan](https://github.com/aradashkan)

Enjoy keeping your FiveM server safe and organized! 🚀
