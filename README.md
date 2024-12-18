# **Bluff**

**Bluff** is an open-source Rails 8 application designed to simplify poker game management and tracking. With a sleek interface and modern features, Bluff helps you manage game sessions, track player stats, visualize trends, and more—all while remaining fully open source.


## **Features**
- **Player Management**: Track wallet balances, loans, and all-time profits.
- **Game Sessions**: Log game details, including chip counts and loans, for each session.
- **Profit Tracking**: Automatically calculate player profits and update their wallets.
- **Charts & Insights**: Visualize player performance and game trends over time.
- **Custom Game Sizes**: Create game types with flexible chip denominations.
- **Progressive Web App (PWA)**: Access Bluff on any device like a native app.


## **Tech Stack**
- **Ruby on Rails 8**: The backbone of Bluff, leveraging Rails' latest features.
- **SQLite**: Lightweight and easy-to-use database for storing data.
- **Hotwire (Turbo + Stimulus)**: For fast and interactive updates without JavaScript overhead.
- **TailwindCSS**: A modern utility-first framework for styling.


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
yarn install
```

3. **Set Up the Database**:

```bash
rails db:setup
```

4. **Run the Server**:

```bash
rails server
```

Visit http://localhost:3000 to access the app.

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
