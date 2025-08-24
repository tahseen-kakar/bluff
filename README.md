# **Bluff**

**Bluff** is an open-source Rails 8 application designed to simplify poker game management and tracking. With a sleek interface and modern features, Bluff helps you manage game sessions, track player stats, visualize trends, and more—all while remaining fully open source.

![Version](https://img.shields.io/badge/version-1.0-blue)
![Rails](https://img.shields.io/badge/Rails-8.0.1-red)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4.1.12-38B2AC)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen)
![Languages](https://img.shields.io/github/languages/top/tahseen-kakar/bluff)
![Last Commit](https://img.shields.io/github/last-commit/tahseen-kakar/bluff)
![PWA Status](https://img.shields.io/badge/PWA-Ready-brightgreen)

## **Features**
- **Player Management**: Track wallet balances, loans, and all-time profits.
- **Game Sessions**: Log game details, including chip counts and loans, for each session.
- **Profit Tracking**: Automatically calculate player profits and update their wallets.
- **Charts & Insights**: Visualize player performance and game trends over time.
- **Custom Game Sizes**: Create game types with flexible chip denominations.
- **Progressive Web App (PWA)**: Access Bluff on any device like a native app.
- **Modern UI**: Clean, responsive interface built with Tailwind CSS v4.

## **Tech Stack**
- **Ruby on Rails 8.0.1**: The backbone of Bluff, leveraging Rails' latest features.
- **SQLite**: Lightweight and easy-to-use database for storing data.
- **Hotwire (Turbo + Stimulus)**: For fast and interactive updates without JavaScript overhead.
- **Tailwind CSS 4.1.12**: Modern CSS-first utility framework with custom color system.
- **Propshaft**: Fast asset pipeline for modern Rails applications.

## **Installation**
Follow these steps to set up Bluff on your local machine:

1. **Clone the Repository**:

```bash
git clone https://github.com/tahseen-kakar/bluff.git
cd bluff
```

2. **Install Dependencies**:

```bash
bundle install
```

3. **Set Up the Database**:

```bash
rails db:setup
```

4. **Run the Development Server**:

```bash
bin/dev
```

Visit http://localhost:3000 to access the app.

## **Development**
For development, Bluff uses:
- **Foreman**: To run Rails server and Tailwind CSS watcher concurrently
- **Tailwind CSS v4**: CSS-first configuration with custom color palettes
- **Modern Rails**: Leveraging Rails 8's latest features and improvements

## **Contributing**
We welcome contributions to Bluff! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description of your changes.

## **License**
Bluff is licensed under the GNU General Public License v3.0. See the LICENSE file for more details.

## **Acknowledgments**
Built with ❤️ for poker and open source.
Inspired by modern Rails development practices and community contributions.

## **Have questions or need help?**
- Open an [issue](https://github.com/tahseen-kakar/bluff/issues).