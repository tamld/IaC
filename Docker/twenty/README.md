<div align="center">
  <img src="https://twenty.com/icon.svg" width="100" />
  
  # Twenty
  **The Modern, Open-Source CRM**
</div>

---

## 👔 What is Twenty CRM?

Twenty is an open-source CRM (Customer Relationship Management) designed to help you track interactions, manage customer pipelines, and organize business entities. Built as an alternative to Hubspot and Salesforce, Twenty's primary strength is giving you absolute control over your core business objects without vendor lock-in.

### ✨ Key Features
- **Total Customization:** Don't constrain yourself to 'Companies' and 'Contacts'. Create *Custom Objects* like 'Invoices', 'Projects', or 'Campaigns'.
- **Relation Mapping:** Link objects with rich relationships (One-to-Many, Many-to-Many).
- **Kanban & List Views:** Visualize your sales pipeline smoothly, similar to modern project management tools like Notion or Linear.
- **API First:** Built with GraphQL and REST APIs enabling flawless integration with your data warehouse or external tools.

---

## ⚙️ Architecture & Compose Configuration

This stack launches the standalone Twenty image. 
*(Note: production deployments of Twenty require external PostgreSQL dependencies for proper data persistence and caching mechanisms, which should be provided via `.env` variables).*

### Port Bindings
- `3000:3000` - Main Twenty web interface and API routing port.

---

## 🚀 Getting Started

### 1. Configure the Environment
Copy the provided `.env.example` to `.env` and configure your database endpoint:
```env
PG_DATABASE_URL=postgres://twenty_user:secure_password@postgres_host:5432/twentydb
FRONT_BASE_URL=http://<your-server-ip>:3000
```

### 2. Boot the Application
Run the container in the background:
```bash
docker compose up -d
```

### 3. Initialize your Workspace
Open your web browser and navigate to `http://<your-server-ip>:3000`. You will be immediately greeted by the setup wizard where you can define your first Administrator account and configure your initial workspace settings. 

---

## 💡 Best Practices

- **Build your Schema First:** Before importing thousands of contacts, navigate to the `Settings -> Workspace -> Objects` page and fully map out the fields and objects your specific business needs.
- **Webhooks:** Use Twenty's Webhooks feature to ping an automation tool like n8n or Make when a pipeline stage changes.